class SendEmailWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(response_list, lead)
    UserMailer.new.lead_creating(response_list, lead)
  end
end
