class ForwardBoberdooRequest
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def perform(lead_id)
    lead = Lead.find_by_id(lead_id)
    SendDataWorker.new.perform(lead.id)

    # Check Responses table and return with JSON response
    response_list = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id)
    if response_list.blank?
      lead.update_attributes(status: Lead::NO_POS)
    end
  end

end

