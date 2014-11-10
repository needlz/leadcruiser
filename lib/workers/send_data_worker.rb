require 'workers/response_petfirst_worker.rb'

class SendDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id, builder)
    return unless builder

    lead = Lead.find(lead_id)
    builder.client_verticals.each do |client|

      provider = DataGeneratorProvider.new(lead, client)

      response = provider.send_data
      binding.pry
      unless response.nil?
        binding.pry
        Response.create(response: response.to_s, lead_id: lead.id)
        if client.integration_name == "pet_first"
          binding.pry
          ResponsePetfirstWorker.perform_async(lead_id)
        end
        break
      end
    end
    # provider = DataGeneratorProvider.new(lead, integration_name)
    # response = provider.send_data
    # if response.nil?
    #   provider = DataGeneratorProviderJson.new(lead, "pet_first")
    #   response = provider.send_data

    #   if response.nil?
    #     ResponsePetfirstWorker.perform_async(lead_id)
    #   end
    # end

    # unless response.nil?
    #   Response.create(response: response.to_s, lead_id: lead.id)
    # end
  end
end
