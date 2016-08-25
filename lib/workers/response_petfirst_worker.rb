class ResponsePetfirstWorker
  include Sidekiq::Worker
  sidekiq_options queue: "low"
  def perform(lead_id)
  	lead = Lead.find_by_id(lead_id)
    PetfirstResponseMailer.new.send_email(lead)
  end
end
