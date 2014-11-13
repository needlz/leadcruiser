class SendEmailWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id)
    lead = Lead.find(lead_id)
    UserMailer.new.lead_creating(lead)
  end
end
