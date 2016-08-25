class AutoResponseThankWorker
  include Sidekiq::Worker
  sidekiq_options queue: "low"
  
  def perform(visitor_email)
    AutoResponseThankMailer.new.send_email(visitor_email)
  end
end
