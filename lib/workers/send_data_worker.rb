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
      provider = DataGeneratorProvider.new(lead, @client)

      response = provider.send_data
      unless response.nil?
        if @client.integration_name == 'pet_premium'
          if response["Response"]["Result"]["Value"] == "BaeOK"
            sold = true
            break
          end
        elsif @client.integration_name == 'pet_first'
          if response["Error"]["ErrorText"] == ""
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
          price: @client.fixed_price
      )
      
      if @client.integration_name == "pet_first"
        ResponsePetfirstWorker.perform_async(lead_id)
        # ResponsePetfirstWorker.new.perform(lead_id)
      end
    end

  end
end
