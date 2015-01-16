class AutoResponseThankWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  
  def perform(visitor_email)
    AutoResponseThankMailer.new.send_email(visitor_email)
  end
end
