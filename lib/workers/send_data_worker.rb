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
    count = 0    
    while response.nil? do
      if count == client_verticals.count
        break
      end
      builder = NextClientBuilder.new(lead, client_verticals)
      @client = ClientsVertical.find_by_integration_name(builder.integration_name)
      provider = DataGeneratorProvider.new(lead, client)

      response = provider.send_data

      count += 1
    end

    unless response.nil?
      Response.create(response: response.to_s, lead_id: lead.id)
      if @client.integration_name == "pet_first"
        ResponsePetfirstWorker.perform_async(lead_id)
        # ResponsePetfirstWorker.new.perform(lead_id)
      end
    end

  end
end
