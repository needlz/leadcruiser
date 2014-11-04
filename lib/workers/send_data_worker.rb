class SendDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id, integration_name)
    return unless integration_name
    lead = Lead.find(lead_id)
    provider = DataGeneratorProvider.new(lead, integration_name)
    response = provider.send_data
    return unless response
    Response.create(response: response.to_s, error_reasons:provider.int_name)
  end
end
