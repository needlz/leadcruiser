class SendDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id)
    lead = Lead.find(lead_id)
    response = DataGeneratorProvider.new(lead).send_data
    Response.create(response: response.to_s, error_reasons: lead.details_pets.last.breed_to_send)
  end
end
