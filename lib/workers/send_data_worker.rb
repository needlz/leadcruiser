class SendDataWorker
  include Sidekiq::Worker

  def perform(lead_id)
    lead = Lead.find(lead_id)
    response = DataGeneratorProvider.new(lead).send_data
    Response.create(response: response.to_s)
  end
end
