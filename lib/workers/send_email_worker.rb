class SendEmailWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(response_id)
    response = Response.find(response_id)
    UserMailer.new.lead_creating(response)
  end
end
