class SendEmailWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def perform(lead_id)
    lead = Lead.find_by_id(lead_id)
    UserMailer.new.lead_creating(lead)
  end
end
