class RequestToInsuranceCareDirect < RequestToClient

  LINK = ""

  attr_reader :health_insurance_lead

  def initialize(lead)
    super(lead)
    @health_insurance_lead = @lead.health_insurance_lead
  end

  def source_id
    481
  end

  def source_code
    'RickTest'
  end

  def passphrase
    'fcunytv51l30v1pujdkog6u3e'
  end

  def generate(exclusive)
    {
      LeadId: health_insurance_lead.tsrc,
      SourceID: source_id,
      SourceCode: source_code,
      Passphrase: passphrase,
      FirstName: lead.first_name,
      LastName: lead.last_name,
      Address: lead.address_1,
      City: lead.city,
      State: lead.state,
      Zip: lead.zip,
      Email: lead.email,
      DayPhone: lead.day_phone,
      EveningPhone: lead.evening_phone,
      DateOfBirth: birth_date,

      Address2: lead.address_2,
      IPAddress: lead.visitor_ip,
      Source: health_insurance_lead.src, # TODO clarify
      LandingPage: health_insurance_lead.landing_page,
      ExistingConditions: preexisting_conditions,
      Gender: gender,
      HeightFT: health_insurance_lead.height_feet,
      HeightIN: health_insurance_lead.height_inches,
      Weight: health_insurance_lead.weight,
      Smoker: smoker
    }
  end

  def gender
    {
      'male': 'M',
      'female': 'F'
    }[lead.gender]
  end

  def preexisting_conditions
    'Yes' if health_insurance_lead.preexisting_conditions == 'yes'
  end

  def smoker
    'Yes' if health_insurance_lead.tobacco_use == 'yes'
  end

  def birth_date
    lead.birth_date.strftime("%Y%m%d") if lead.birth_date
  end

  def success?
    response.parsed_response['PostResponse']['isValidPost'] == 'True' && response.parsed_response['PostResponse']['ResponseType'] == 'No_Error'
  end

  def rejection_reason
    response
  end

end


