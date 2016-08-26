class SendEmailWorker
  include Sidekiq::Worker
  sidekiq_options queue: "low"
  def perform(response_id_list, lead_id)
    UserMailer.new.lead_creating(response_id_list, lead_id)
  end
end
