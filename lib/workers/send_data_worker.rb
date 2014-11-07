class SendDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id, integration_name)
    return unless integration_name
    lead = Lead.find(lead_id)
    provider = DataGeneratorProvider.new(lead, integration_name)
    response = provider.send_data
    if response.nil?
      provider = DataGeneratorProviderJson.new(lead, "pet_first")
      response = provider.send_data
    end

    # provider = DataGeneratorProviderJson.new(lead, "pet_first")
    # response = provider.send_data

    # unless response.nil?
    #   Response.create(response: response.to_s, lead_id: lead.id)
    # end
  end
end
