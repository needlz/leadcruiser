require 'workers/response_petfirst_worker.rb'
require 'workers/send_email_worker.rb'

class SendDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  attr_accessor :client

  NO_EXCLUSIVE_POS = "No matching exclusive purchase orders"
  NO_SHARED_POS = "No matching shared purchase orders"
  NIL_RESPONSE = "Nil response"
  
  def perform(lead_id)
    return unless lead_id

    lead = Lead.find(lead_id)

    # Get available exclusive and shared POs
    po_builder = PurchaseOrderBuilder.new(lead)
    exclusive_po_length = po_builder.exclusive_pos_length
    shared_po_length = po_builder.shared_pos_length

    if exclusive_po_length == 0
      record_transaction lead_id, nil, nil, nil, nil, false, nil, NO_EXCLUSIVE_POS, nil
    end
    if shared_po_length == 0
      record_transaction lead_id, nil, nil, nil, nil, false, nil, NO_SHARED_POS, nil
    end

    # Initialize algorithm variables
    used_shared_po_id_list  = []
    used_exclusive_po_id_list = []
    current_shared_pos = []
    current_exclusive_po = nil
    current_shared_po = nil

    while used_exclusive_po_id_list.length != exclusive_po_length || used_shared_po_id_list.length != shared_po_length
      exclusive_po = po_builder.next_exclusive_po(current_exclusive_po, used_exclusive_po_id_list)
      current_shared_pos = po_builder.next_shared_pos(current_shared_po, used_shared_po_id_list, lead.vertical.times_sold)
      shared_pos_price_sum = 0

      # Calculate exclusive and shared POs' price
      if current_shared_pos.length != 0
        for i in 0..current_shared_pos.length - 1
          shared_pos_price_sum += current_shared_pos[i][:real_price]
        end
      end
      
      exclusive_price = 0
      unless exclusive_po.nil?
        exclusive_price = exclusive_po[:real_price]
      end

      # Compare the price
      is_exclusive = true
      if shared_pos_price_sum > exclusive_price
        is_exclusive = false
      end

      # Exclusive selling is selected by price
      if is_exclusive && !exclusive_po.nil?
        client = ClientsVertical.where(active: true, id: exclusive_po[:client_id]).try(:first)
        provider = DataGeneratorProvider.new(lead, client)

        response = provider.send_data
        sold = check_response(lead, response, client, exclusive_po, true)
        used_exclusive_po_id_list.push exclusive_po[:id]
        current_exclusive_po = exclusive_po

        if sold
          update_po_attribute(current_exclusive_po, client, lead)
          break
        end
      else
        # Shared selling is selected by price
        failed_count = 0
        shared_selling = false
        for i in 0..current_shared_pos.length - 1
          client = ClientsVertical.where(active:true, id: current_shared_pos[i][:client_id]).try(:first)
          provider = DataGeneratorProvider.new(lead, client)
          response = provider.send_data(false)
          sold = check_response(lead, response, client, current_shared_pos[i])
          used_shared_po_id_list.push current_shared_pos[i][:id]
          current_shared_po = current_shared_pos[i]
          if !sold
            if !shared_selling
              break
            else
              failed_count += 1
            end
          else
            shared_selling = true
            update_po_attribute(current_shared_po, client, lead)
          end
        end

        if !shared_selling
          next
        end

        if failed_count == 0
          break
        end

        if shared_selling
          new_shared_pos = []
          while failed_count != 0
            new_shared_pos = po_builder.next_shared_pos(current_shared_po, used_shared_po_id_list, failed_count)

            if new_shared_pos.length == 0
              break
            end

            for i in 0..new_shared_pos.length - 1
              client = ClientsVertical.where(active:true, id: new_shared_pos[i][:client_id]).try(:first)
              provider = DataGeneratorProvider.new(lead, client)
              response = provider.send_data(false)
              sold = check_response(lead, response, client, new_shared_pos[i])

              used_shared_po_id_list.push new_shared_pos[i][:id]
              current_shared_po = new_shared_pos[i]
              if sold
                update_po_attribute(current_shared_po, client, lead)
                failed_count -= 1
              end
            end          
          end
        else
          next
        end

        break
      end
    end
  end

  private

  def update_po_attribute(po, client, lead)
    purchase_order = PurchaseOrder.find po[:id]
    purchase_order.update_attributes :leads_count_sold => purchase_order.leads_count_sold + 1,
                                     :daily_leads_count => purchase_order.daily_leads_count + 1

    if client.integration_name == "pet_first" && purchase_order.exclusive
      ResponsePetfirstWorker.perform_async(lead.id)
      # ResponsePetfirstWorker.new.perform(lead.id)
    end
  end

  def check_response(lead, response, client, purchase_order, exclusive_selling=false)
    sold = false
    unless response.nil?
      if client.integration_name == ClientsVertical::HEALTHY_PAWS
        start_pos = response.index("<pre>")
        end_pos = response.index("</pre>")
        unless start_pos.nil?
          response = response[start_pos+6..end_pos-2]
        end
      end

      rejection_reasons = nil
      resp_model = Response.create(
          response: response.to_s, 
          lead_id: lead.id, 
          client_name: client.integration_name
      )
      if client.integration_name == ClientsVertical::PET_PREMIUM
        if response["Response"]["Result"]["Value"] == "BaeOK"
          sold = true
        else
          rejection_reasons = response["Response"]["Result"]["Error"].to_s
        end
      elsif client.integration_name == ClientsVertical::PET_FIRST
        if response["Error"]["ErrorText"] == ""
          sold = true
        else
          rejection_reasons = response["Error"]["ErrorText"].to_s
        end
      elsif client.integration_name == ClientsVertical::PETS_BEST
        if response["Status"] == "Success" and response["Message"].nil?
          sold = true
        else
          rejection_reasons = response["Message"].to_s
        end
      elsif client.integration_name == ClientsVertical::HEALTHY_PAWS
        if response == "SUCCESS"
          sold = true
        else
          rejection_reasons = response
          sold = false
        end
      else
        if !response["success"].nil? && response["success"]
          sold = true
        end

        if !response["errors"].nil? && response["errors"]
          sold = false
          rejection_reasons = "Test Failure"
        end
      end

      if sold && !resp_model.nil?
        # Update reponse
        resp_model.update_attributes :price => purchase_order[:real_price], :purchase_order_id => purchase_order[:id]

        # Update lead
        lead.times_sold = lead.times_sold.to_i + 1
        lead.total_sale_amount = lead.total_sale_amount.to_i + purchase_order[:real_price]
        lead.update_attributes :status => Lead::SOLD

        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        record_transaction lead.id, client.id, resp_model.purchase_order_id, po_history.price, po_history.weight, true, exclusive_selling, nil, resp_model.id

        sold = true        
      elsif !sold && !resp_model.nil?
        resp_model.update_attributes :rejection_reasons => rejection_reasons

        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        record_transaction lead.id, client.id, purchase_order[:id], po_history.price, po_history.weight, false, exclusive_selling, rejection_reasons, resp_model.id
      end
    else
      sold = false
      
      # Record transaction history
      po_history = PurchaseOrder.find purchase_order[:id]
      record_transaction lead.id, client.id, purchase_order[:id], po_history.price, po_history.weight, false, exclusive_selling, NIL_RESPONSE, nil      
    end    

    sold
  end

  def check_purchase_order(lead, client)
    pos = PurchaseOrder.where('vertical_id = ? and client_id = ? and active = ? and exclusive = ?', 
                                @client.vertical_id, @client.id, true, true)
    if pos.nil? || pos.length == 0
      nil
    else
      pos.each do |po|
        # Check states
        state = lead.state || lead.try(:zip_code).try(:state)
        unless po.states.nil?
          state_filter_array = po.states.split(/,/)
          # Remove whitespace in the code
          for i in 0..state_filter_array.length-1
            state_filter_array[i] = state_filter_array[i].strip
          end
          if state_filter_array.length > 0 and !state_filter_array.include? state
            # binding.pry
            next
          end
        end

        # Check preexisting conditions
        pet = lead.details_pets.first
        if !po.preexisting_conditions.nil? and po.preexisting_conditions != pet.conditions
          # binding.pry
          next
        end

        # Check Maximum leads limit
        if !po.leads_max_limit.nil? and po.leads_count_sold >= po.leads_max_limit
          # binding.pry
          next
        end

        # Check Daily leads limit
        if !po.leads_daily_limit.nil? and po.daily_leads_count >= po.leads_daily_limit
          # binding.pry
          next
        end

        # Check Date
        if !po.start_date.nil? and po.start_date > Date.today
          # binding.pry
          next
        end

        if !po.end_date.nil? and po.end_date < Date.today
          # binding.pry
          next
        end
        

        return po
      end
    end

    nil
  end

  def record_transaction(
    lead_id, client_id=nil, po_id=nil, price=nil, weight=nil, success=false, 
    exclusive_selling=nil, reason=nil, response_id=nil)

    unless lead_id.nil?
      TransactionAttempt.create(
        lead_id: lead_id,
        client_id: client_id,
        purchase_order_id: po_id,
        price: price,
        weight: weight,
        success: success,
        exclusive_selling: exclusive_selling,
        reason: reason,
        response_id: response_id
      )
    end
  end
end
