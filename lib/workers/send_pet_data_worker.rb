require 'workers/response_petfirst_worker.rb'
require 'workers/send_email_worker.rb'

class SendPetDataWorker
  extend ActionView::Helpers::NumberHelper

  attr_accessor :client

  NO_EXCLUSIVE_POS = "No matching exclusive purchase orders"
  NO_SHARED_POS = "No matching shared purchase orders"
  NIL_RESPONSE = "Nil response"
  
  def perform(lead_id)
    return unless lead_id

    lead = Lead.find(lead_id)

    # Get available exclusive and shared POs
    purchase_orders_query = PurchaseOrderQuery.new(lead)
    exclusive_po_length = purchase_orders_query.exclusive_pos_length
    shared_po_length = purchase_orders_query.shared_pos_length

    if exclusive_po_length == 0
      SendPetDataWorker.record_transaction(lead_id: lead_id,
                                           success: false,
                                           reason: NO_EXCLUSIVE_POS)
    end
    if shared_po_length == 0
      SendPetDataWorker.record_transaction(lead_id: lead_id,
                                           success: false,
                                           reason: NO_SHARED_POS)
    end

    # Initialize algorithm variables
    used_shared_po_id_list  = []
    used_exclusive_po_id_list = []
    current_shared_pos = []
    current_exclusive_po = nil
    current_shared_po = nil

    while used_exclusive_po_id_list.length != exclusive_po_length || used_shared_po_id_list.length != shared_po_length
      exclusive_po = purchase_orders_query.next_exclusive_purchase_order(current_exclusive_po, used_exclusive_po_id_list)
      current_shared_pos = purchase_orders_query.next_shared_purchase_orders(current_shared_po, used_shared_po_id_list, lead.vertical.times_sold)
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

      # Compare the price between exclusive and shared
      is_exclusive = true
      if shared_pos_price_sum > exclusive_price
        is_exclusive = false
      elsif exclusive_price > shared_pos_price_sum
        is_exclusive = true
      else
        # Run round-robin rotation
        vt = lead.vertical
        if vt.next_client.nil?
          is_exclusive = true
          lead.vertical.update_attributes(:next_client => "Shared")
        else
          if vt.next_client == "Exclusive"
            is_exclusive = true
            lead.vertical.update_attributes(:next_client => "Shared")
          else
            is_exclusive = false
            lead.vertical.update_attributes(:next_client => "Exclusive")
          end
        end
      end

      # Exclusive selling is selected by price
      if is_exclusive && !exclusive_po.nil?
        client = ClientsVertical.where(active: true, id: exclusive_po[:client_id]).try(:first)
        request = RequestToClientGenerator.new(lead, client)

        start = Time.now
        response = request.send_data
        finish = Time.now
        diff = finish - start

        sold = SendPetDataWorker.check_response(response, lead, request.generator, client, exclusive_po, diff, true)
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
          request = RequestToClientGenerator.new(lead, client)

          start = Time.now
          response = request.send_data(false)
          finish = Time.now
          diff = finish - start

          sold = SendPetDataWorker.check_response(response, lead, request.generator, client, current_shared_pos[i], diff)
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
            new_shared_pos = purchase_orders_query.next_shared_purchase_orders(current_shared_po, used_shared_po_id_list, failed_count)
            if new_shared_pos.length == 0
              break
            end

            for i in 0..new_shared_pos.length - 1
              client = ClientsVertical.where(active:true, id: new_shared_pos[i][:client_id]).try(:first)
              request = RequestToClientGenerator.new(lead, client)
              
              start = Time.now
              response = request.send_data(false)
              finish = Time.now
              diff = finish - start

              sold = SendPetDataWorker.check_response(response, lead, request.generator, client, new_shared_pos[i], diff)

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

  def self.record_transaction(transaction_attributes)
    TransactionAttempt.create(transaction_attributes) if transaction_attributes[:lead_id]
  end

  def self.check_response(response, lead, request, client, purchase_order, response_time, exclusive_selling = false)
    response_time = number_with_precision(response_time, precision: 2)
    sold = false

    if response
      # Request timeout
      if response == "Timeout" || response == "IOError"
        resp_model = Response.create(
          rejection_reasons: 'Timeout', 
          lead_id: lead.id, 
          client_name: client.integration_name,
          response_time: response_time
        )

        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        record_transaction(lead_id: lead.id,
                           client_id: client.id,
                           purchase_order_id: purchase_order[:id],
                           price: po_history.price,
                           weight: po_history.weight,
                           success: false,
                           exclusive_selling: exclusive_selling,
                           reason: response,
                           response_id: resp_model.id)
        return sold
      end

      # If the client is Healthy Paws, remove HTML tags from the original reponses
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
          client_name: client.integration_name,
          response_time: response_time
      )
      sold = request.success?
      rejection_reasons = request.rejection_reason unless sold

      if sold && !resp_model.nil?
        # Update reponse
        resp_model.update_attributes :price => purchase_order[:real_price], :purchase_order_id => purchase_order[:id]

        # Update lead
        lead.times_sold = lead.times_sold.to_i + 1
        if lead.total_sale_amount.nil?
          lead.total_sale_amount = 0
        end
        
        # Total sale amount of a lead should not include the weight into the calculation, should only be the sum of the PO price
        # lead.total_sale_amount = lead.total_sale_amount + purchase_order[:real_price]
        lead.total_sale_amount = lead.total_sale_amount + purchase_order[:price]

        lead.sold!

        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        record_transaction(        lead_id: lead.id,
                                   client_id: client.id,
                                   purchase_order_id: resp_model.purchase_order_id,
                                   price: po_history.price,
                                   weight: po_history.weight,
                                   success: true,
                                   exclusive_selling: exclusive_selling,
                                   reason: nil,
                                   response_id: resp_model.id)
        sold = true
      elsif !sold && !resp_model.nil?
        resp_model.update_attributes :rejection_reasons => rejection_reasons

        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        record_transaction(        lead_id: lead.id,
                                   client_id: client.id,
                                   purchase_order_id: purchase_order[:id],
                                   price: po_history.price,
                                   weight: po_history.weight,
                                   success: false,
                                   exclusive_selling: exclusive_selling,
                                   reason: rejection_reasons,
                                   response_id: resp_model.id)
      end
    else
      sold = false
      
      # Record transaction history
      po_history = PurchaseOrder.find purchase_order[:id]
      record_transaction(        lead_id: lead.id,
                                 client_id: client.id,
                                 purchase_order_id: purchase_order[:id],
                                 price: po_history.price,
                                 weight: po_history.weight,
                                 success: false,
                                 exclusive_selling: exclusive_selling,
                                 reason: NIL_RESPONSE,
                                 response_id: nil)
    end

    sold
  end

  def update_po_attribute(po, client, lead)
    purchase_order = PurchaseOrder.find po[:id]
    purchase_order.update_attributes :leads_count_sold => purchase_order.leads_count_sold.to_i + 1,
                                     :daily_leads_count => purchase_order.daily_leads_count.to_i + 1

    if client.integration_name == "pet_first" && purchase_order.exclusive
      ResponsePetfirstWorker.perform_async(lead.id)
    end
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
            next
          end
        end

        # Check preexisting conditions
        pet = lead.details_pets.first
        if !po.preexisting_conditions.nil? and po.preexisting_conditions != pet.conditions
          next
        end

        # Check Maximum leads limit
        if !po.leads_max_limit.nil? and !po.leads_count_sold.nil? and po.leads_count_sold >= po.leads_max_limit
          next
        end

        # Check Daily leads limit
        if !po.leads_daily_limit.nil? and !po.daily_leads_count.nil? and po.daily_leads_count >= po.leads_daily_limit
          next
        end

        # Check Date
        if !po.start_date.nil? and po.start_date > Date.today
          next
        end

        if !po.end_date.nil? and po.end_date < Date.today
          next
        end
        

        return po
      end
    end

    nil
  end

end
