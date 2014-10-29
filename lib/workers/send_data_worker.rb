class SendDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id)
    lead = Lead.find(lead_id)
    response = DataGeneratorProvider.new(lead).send_data
    return unless response
    Response.create(response: response.to_s)
  end
end
