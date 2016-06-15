class BoberdooGenerator < ClientRequestGenerator

  LINK = ''

  def initialize(lead)
    @lead = lead
  end

  def generate(exclusive)
    form = HealthInsuranceLeadForm.new({})
    form.lead = lead
    form.health_insurance_lead = lead.health_insurance_lead
    form.boberdoo_params
  end

  private

  def perform_http_request(exclusive)
    HTTParty.get request_url,
                 :query => generate(exclusive),
                 :headers => request_header,
                 :timeout => client.timeout
  end

end