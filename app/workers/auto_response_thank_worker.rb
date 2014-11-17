class AutoResponseThankWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  
  def perform(lead_id)
    AutoResponseThankMailer.new.send_email(lead_id)
  end
end
