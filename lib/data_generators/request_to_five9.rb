class RequestToFive9 < RequestToClient

  CAMPAIGNS = {
    RequestToBoberdoo::HEALTH_INSURANCE_TYPE => {
      'healthmatchup.com' => '(LC) HealthMatchup Health',
      'gethealthcare.co' => 'LeadCruiser Proxy (GH Health)'
    },
    RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE => {
      'healthmatchup.com' => '(LC) HealthMatchup MedSupp',
      'gethealthcare.co' => 'LeadCruiser Proxy (GH MedSupp)'
    }
  }

  def generate(_); end

  def request_url
    params = lead_params.merge(list_params)
    params_url = URI.encode_www_form(params)
    client.service_url + '?' + params_url
  end

  def perform_http_request(exclusive)
    response = super(exclusive)
    parse_html(response)
  end

  def parse_html(html)
    Nokogiri::HTML(html)
  end

  def success?
    result = response.at_css('input[name=F9errDesc]').attr('value')
    successful_result?(result)
  end

  def rejection_reason
    result = response.at_css('input[name=F9errDesc]').attr('value')
    result unless successful_result?(result)
  end

  def successful_result?(result)
    result == "The request was successfully processed"
  end

  def list_name
    'LeadcruiserPostedLeadsNEW'
  end

  def domain_name
    'Promise Insurance'
  end

  def list_params
    {
      F9domain: domain_name,
      F9list: list_name
    }
  end

  def lead_params
    {
      number1: lead.day_phone,
      first_name: lead.first_name,
      last_name: lead.last_name,
      street: lead.address_1,
      city: lead.city,
      state: lead.state,
      zip: lead.zip,
      leadId: lead.id,

      email: lead.email,
      gender: lead.gender,
      created_at: lead.created_at.try(:strftime, "%m/%d/%Y %H:%M:%S"),
      fpl: lead.health_insurance_lead.fpl,
      lead_type: lead.health_insurance_lead.lead_type,
      qualifying_life_event: lead.health_insurance_lead.qualifying_life_event,
      src: lead.health_insurance_lead.src,
      birth_date: birth_date,
      ref: lead.health_insurance_lead.ref,
      preexisting_conditions: lead.health_insurance_lead.preexisting_conditions,
      spouse_age: lead.health_insurance_lead.spouse_age,
      spouse_gender: lead.health_insurance_lead.spouse_gender,
      household_size: lead.health_insurance_lead.household_size,
      household_income: lead.health_insurance_lead.household_income,
      height_feet: lead.health_insurance_lead.height_feet,
      height_inches: lead.health_insurance_lead.height_inches,
      weight: lead.health_insurance_lead.weight,
      Campaign: campaign
    }
  end

  def birth_date
    if lead.birth_date
      lead.birth_date.try(:strftime, '%m/%d/%Y')
    elsif lead.health_insurance_lead.age
      Time.current.ago(lead.health_insurance_lead.age.years).try(:strftime, '%m/%d/%Y')
    end
  end

  def campaign
    CAMPAIGNS[lead.health_insurance_lead.boberdoo_type][lead.site.domain]
  end

end
