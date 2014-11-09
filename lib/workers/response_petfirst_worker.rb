class ResponsePetfirstWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  def perform(lead_id)
    PetfirstResponseMailer.new.send_email(lead_id)
  end
end
