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
      Gender: gender(lead.gender),
      HeightFT: health_insurance_lead.height_feet,
      HeightIN: health_insurance_lead.height_inches,
      Weight: health_insurance_lead.weight,
      Smoker: smoker(health_insurance_lead.tobacco_use),
      Income: health_insurance_lead.household_income,

      SpousePreExistingConditions: ('Yes' if health_insurance_lead.spouse_preexisting_conditions == 'yes'),
      SpouseGender: gender(health_insurance_lead.spouse_gender),
      SpouseHeightFT: health_insurance_lead.spouse_height_feet,
      SpouseHeightIN: health_insurance_lead.spouse_height_inches,
      SpouseSmoker: smoker(health_insurance_lead.spouse_tobacco_use),
      SpouseWeight: health_insurance_lead.spouse_weight,

      Child1PreExistingConditions: ('Yes' if health_insurance_lead.child_1_preexisting_conditions == 'yes'),
      Child1Gender: gender(health_insurance_lead.child_1_gender),
      Child1HeightFT: health_insurance_lead.child_1_height_feet,
      Child1HeightIN: health_insurance_lead.child_1_height_inches,
      Child1Smoker: smoker(health_insurance_lead.child_1_tobacco_use),
      Child1Weight: health_insurance_lead.child_1_weight,

      Child2PreExistingConditions: ('Yes' if health_insurance_lead.child_2_preexisting_conditions == 'yes'),
      Child2Gender: gender(health_insurance_lead.child_2_gender),
      Child2HeightFT: health_insurance_lead.child_2_height_feet,
      Child2HeightIN: health_insurance_lead.child_2_height_inches,
      Child2Smoker: smoker(health_insurance_lead.child_2_tobacco_use),
      Child2Weight: health_insurance_lead.child_2_weight,

      Child3PreExistingConditions: ('Yes' if health_insurance_lead.child_3_preexisting_conditions == 'yes'),
      Child3Gender: gender(health_insurance_lead.child_3_gender),
      Child3HeightFT: health_insurance_lead.child_3_height_feet,
      Child3HeightIN: health_insurance_lead.child_3_height_inches,
      Child3Smoker: smoker(health_insurance_lead.child_3_tobacco_use),
      Child3Weight: health_insurance_lead.child_3_weight,
    }
  end

  def gender(g)
    {
      'male': 'M',
      'female': 'F'
    }[g]
  end

  def preexisting_conditions
    'Yes' if health_insurance_lead.preexisting_conditions == 'yes'
  end

  def smoker(use)
    'Yes' if use == 'yes'
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
