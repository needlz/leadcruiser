class AddSendgridContactJob < ActiveJob::Base
  queue_as :high

  def perform(lead_id)
    lead = Lead.find(lead_id)
    AddSendgridContact.new(lead).perform
  end
end
