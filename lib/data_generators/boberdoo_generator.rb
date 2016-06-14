require 'nokogiri'

class BoberdooGenerator

  LINK = ""

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def generate(exclusive)
    form = HealthInsuranceLeadForm.new({})
    form.lead = lead
    form.health_insurance_lead = lead.health_insurance_lead
    form.boberdoo_params
  end

end