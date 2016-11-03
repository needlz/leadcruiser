class AddSendgridContact

  class Error < StandardError; end

  attr_reader :lead

  def initialize(lead)
    @lead = lead
  end

  def perform
    response = do_request
    response_hash = JSON.parse(response.body)
    raise Error.new(response_hash) if response_hash['error_count'] > 0
  end

  def api
    @api ||= SendGrid::API.new(api_key: Settings.sendgrid_api_key)
  end

  def request_data
    [{
       Birth_Date: (lead.birth_date.strftime("%m/%d/%Y") if lead.birth_date),
       email: lead.email,
       first_name: lead.first_name,
       last_name: lead.last_name,
       Zip: lead.zip,
       Gender: lead.gender,
       Lead_Type: lead.health_insurance_lead.lead_type,
       FPL: lead.health_insurance_lead.fpl,
       Life_Event: lead.health_insurance_lead.qualifying_life_event
     }]
  end

  def do_request
    api.client.contactdb.recipients.post(request_body: request_data)
  end

end
