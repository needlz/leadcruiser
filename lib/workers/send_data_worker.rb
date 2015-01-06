require 'workers/response_petfirst_worker.rb'

class SendDataWorker

  attr_accessor :client

  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id)
    return unless lead_id

    lead = Lead.find(lead_id)

    po_builder = PurchaseOrderBuilder.new(lead)
    exclusive_po_length = po_builder.exclusive_pos_length
    shared_po_length = po_builder.shared_pos_length


    # rejected_po_id_list = []
    # exclusive_po = nil
    # while rejected_po_id_list.length != exclusive_po_length
    #   binding.pry
    #   exclusive_po = po_builder.next_exclusive_po(exclusive_po, rejected_po_id_list)
    #   binding.pry
    #   rejected_po_id_list.push exclusive_po[:id]
    # end
    # binding.pry

    # rejected_po_id_list = []
    # shared_po = nil
    # while rejected_po_id_list.length != shared_po_length
    #   binding.pry
    #   shared_pos = po_builder.next_shared_pos(shared_po, rejected_po_id_list)
    #   binding.pry
    #   for i in 0..shared_pos.length-1
    #     rejected_po_id_list.push shared_pos[i][:id]
    #     shared_po = shared_pos[i]
    #   end
    # end

    used_shared_po_id_list  = []
    used_exclusive_po_id_list = []
    current_shared_pos = []
    current_exclusive_po = nil
    current_shared_po = nil

    while used_exclusive_po_id_list.length != exclusive_po_length || used_shared_po_id_list.length != shared_po_length
      exclusive_po = po_builder.next_exclusive_po(current_exclusive_po, used_exclusive_po_id_list)
      current_shared_pos = po_builder.next_shared_pos(current_shared_po, used_shared_po_id_list, lead.vertical.times_sold)
      shared_pos_price_sum = 0

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

      if is_exclusive && !exclusive_po.nil?
        client = ClientsVertical.where(active: true, integration_name: exclusive_po[:client_name]).try(:first)
        provider = DataGeneratorProvider.new(lead, client)

        response = provider.send_data
        sold = check_response(lead, response, client, exclusive_po)
        used_exclusive_po_id_list.push exclusive_po[:id]
        current_exclusive_po = exclusive_po

        if sold
          update_po_attribute(current_exclusive_po, client, lead)
          break
        end
      else
        failed_count = 0
        shared_selling = false
        for i in 0..current_shared_pos.length - 1
          client = ClientsVertical.where(active:true, integration_name: current_shared_pos[i][:client_name]).try(:first)
          provider = DataGeneratorProvider.new(lead, client)
          response = provider.send_data
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
              client = ClientsVertical.where(active:true, integration_name: new_shared_pos[i][:client_name]).try(:first)
              provider = DataGeneratorProvider.new(lead, client)
              response = provider.send_data
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

    ########################
    # client_verticals = ClientsVertical.where(vertical_id: lead.vertical_id, active: true, exclusive: true)
    
    # response = nil
    # sold = false
    # count = 0    
    # while !sold do
    #   if count == client_verticals.count
    #     break
    #   end
    #   builder = NextClientBuilder.new(lead, client_verticals)
    #   @client = ClientsVertical.where(active: true, integration_name: builder.integration_name).first

    #   purchase_order = check_purchase_order(lead, @client)
    #   if purchase_order.nil?
    #     # binding.pry
    #     count += 1
    #     next
    #   end

    #   provider = DataGeneratorProvider.new(lead, @client)
    #   response = provider.send_data
    #   puts response
    #   # Check response message is success or failure.
    #   unless response.nil?
    #     rejection_reasons = nil
    #     resp_model = Response.create(
    #         response: response.to_s, 
    #         lead_id: lead.id, 
    #         client_name: @client.integration_name
    #     )
    #     if @client.integration_name == ClientsVertical::PET_PREMIUM
    #       if response["Response"]["Result"]["Value"] == "BaeOK"
    #         sold = true
    #       else
    #         rejection_reasons = response["Response"]["Result"]["Error"].to_s
    #       end
    #     elsif @client.integration_name == ClientsVertical::PET_FIRST
    #       if response["Error"]["ErrorText"] == ""
    #         sold = true
    #       else
    #         rejection_reasons = response["Error"]["ErrorText"].to_s
    #       end
    #     elsif @client.integration_name == ClientsVertical::PETS_BEST
    #       if response["Status"] == "Success" and response["Message"].nil?
    #         sold = true
    #       else
    #         rejection_reasons = response["Message"].to_s
    #       end
    #     end

    #     if sold && !resp_model.nil?
    #       resp_model.update_attributes :price => purchase_order.price, :purchase_order => purchase_order
    #       break
    #     elsif !sold && !resp_model.nil?
    #       resp_model.update_attributes :rejection_reasons => rejection_reasons
    #     end
    #   end

    #   count += 1
    # end

    # if sold
    #   purchase_order.update_attributes :leads_count_sold => purchase_order.leads_count_sold + 1,
    #                                    :daily_leads_count => purchase_order.daily_leads_count + 1
      
    #   if @client.integration_name == "pet_first"
    #     ResponsePetfirstWorker.perform_async(lead_id)
    #     # ResponsePetfirstWorker.new.perform(lead_id)
    #   end
    # end
    ###############################################

  end

  private

  def update_po_attribute(po, client, lead)
    purchase_order = PurchaseOrder.find po[:id]
    purchase_order.update_attributes :leads_count_sold => purchase_order.leads_count_sold + 1,
                                     :daily_leads_count => purchase_order.daily_leads_count + 1

    if client.integration_name == "pet_first"
      ResponsePetfirstWorker.perform_async(lead.id)
      ResponsePetfirstWorker.new.perform(lead.id)
    end
  end

  def check_response(lead, response, client, purchase_order)
    sold = false
    unless response.nil?
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

        sold = true        
      elsif !sold && !resp_model.nil?
        resp_model.update_attributes :rejection_reasons => rejection_reasons
      end
    end    

    sold
  end

  def check_purchase_order(lead, client)
    pos = PurchaseOrder.where('vertical_id = ? and client_name = ? and active = ? and exclusive = ?', 
                                @client.vertical_id, @client.integration_name, true, true)
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
end
