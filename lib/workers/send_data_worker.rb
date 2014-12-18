require 'workers/response_petfirst_worker.rb'

class SendDataWorker

  attr_accessor :client

  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id)
    return unless lead_id

    lead = Lead.find(lead_id)
    client_verticals = ClientsVertical.where(vertical_id: lead.vertical_id, active: true, exclusive: true)
    
    response = nil
    sold = false
    count = 0    
    while !sold do
      if count == client_verticals.count
        break
      end
      builder = NextClientBuilder.new(lead, client_verticals)
      @client = ClientsVertical.where(active: true, integration_name: builder.integration_name).first

      purchase_order = check_purchase_order(lead, @client)
      if purchase_order.nil?
        # binding.pry
        count += 1
        next
      end
      # if @client.integration_name == ClientsVertical::PETS_BEST
      #   state_filter = ["CA", "NY", "TX", "CO", "FL", "NJ", "AZ", "NV", "IL", "VA"]
      #   state = lead.state || lead.try(:zip_code).try(:state)
      #   unless state_filter.include? state
      #     count += 1
      #     next
      #   end
      # end

      provider = DataGeneratorProvider.new(lead, @client)
      response = provider.send_data
      # binding.pry
      # Check response message is success or failure.
      unless response.nil?
        if @client.integration_name == ClientsVertical::PET_PREMIUM
          if response["Response"]["Result"]["Value"] == "BaeOK"
            sold = true
            break
          end
        elsif @client.integration_name == ClientsVertical::PET_FIRST
          if response["Error"]["ErrorText"] == ""
            sold = true
            break
          end
        elsif @client.integration_name == ClientsVertical::PETS_BEST
          if response["Status"] == "Success" and response["Message"].nil?
            sold = true
            break
          end
        end
      end

      count += 1
    end

    if sold
      Response.create(
          response: response.to_s, 
          lead_id: lead.id, 
          client_name: @client.integration_name, 
          price: purchase_order.price,
          purchase_order: purchase_order
      )

      purchase_order.update_attributes :leads_count_sold => purchase_order.leads_count_sold + 1,
                                       :daily_leads_count => purchase_order.daily_leads_count + 1
      
      if @client.integration_name == "pet_first"
        ResponsePetfirstWorker.perform_async(lead_id)
        # ResponsePetfirstWorker.new.perform(lead_id)
      end
    end

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
        state_filter_array = po.states.split(/,/)
        # Remove whitespace in the code
        for i in 0..state_filter_array.length-1
          state_filter_array[i] = state_filter_array[i].strip
        end
        unless state != "" and state_filter_array.include? state
          # binding.pry
          next
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
