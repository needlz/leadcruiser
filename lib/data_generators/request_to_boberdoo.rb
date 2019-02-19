class RequestToBoberdoo < RequestToClient

  LINK = ''
  HEALTH_INSURANCE_TYPE = '21'
  MEDICARE_SUPPLEMENT_INSURANCE_TYPE = '23'

  attr_reader :health_insurance_lead

  def initialize(lead)
    super(lead)
    @health_insurance_lead = @lead.health_insurance_lead
  end

  def generate(exclusive)
    send("params_for_type_#{ health_insurance_lead.boberdoo_type }")
  end

  def success?
    ["UNMATCHED", "MATCHED", "Matched", "Unmatched"].include?(response['response']['status'])
  end

  def rejection_reason
    response['response']['error']
  end

  private

  def source
    if successful_response_from_ICD?
      health_insurance_lead.src == 'HealthMatchup' ? 'HealthMatchup2' : health_insurance_lead.src
    else
      health_insurance_lead.src
    end
  end

  def successful_response_from_ICD?
    icd = ClientsVertical.find_by_integration_name(ClientsVertical::ICD)
    return false unless icd
    lead.transaction_attempts.where(client_id: icd.id).successful.exists?
  end

  def params_for_type_21
    params = {
      TYPE: HEALTH_INSURANCE_TYPE,
      Test_Lead: health_insurance_lead.test_lead,
      Skip_XSL: health_insurance_lead.skip_xsl,
      Match_With_Partner_ID: health_insurance_lead.match_with_partner_id,
      Redirect_URL: health_insurance_lead.redirect_url,
      SRC: source,
      Landing_Page: health_insurance_lead.landing_page,
      IP_Address: lead.visitor_ip,
      Sub_ID: health_insurance_lead.sub_id,
      Pub_ID: health_insurance_lead.pub_id,
      Optout: health_insurance_lead.optout,
      imbx: health_insurance_lead.imbx,
      Ref: health_insurance_lead.ref,
      user_agent: health_insurance_lead.user_agent,
      tsrc: health_insurance_lead.tsrc,
      First_Name: lead.first_name,
      Last_Name: lead.last_name,
      Address_1: lead.address_1,
      Address_2: lead.address_2,
      City: lead.city,
      State: lead.state,
      Zip: lead.zip,
      Phone_Number: lead.day_phone,
      Email_Address: lead.email,
      FPL: health_insurance_lead.fpl,
      DOB: birth_date,
      Gender: lead.gender,
      Age: health_insurance_lead.age,
      Height_Feet: health_insurance_lead.height_feet,
      Height_Inches: health_insurance_lead.height_inches,
      Weight: health_insurance_lead.weight,
      Tobacco_Use: health_insurance_lead.tobacco_use,
      Preexisting_Conditions: health_insurance_lead.preexisting_conditions,
      Household_Income: health_insurance_lead.household_income,
      Household_Size: health_insurance_lead.household_size,
      Qualifying_Life_Event: health_insurance_lead.qualifying_life_event,
      Spouse_Gender: health_insurance_lead.spouse_gender,
      Spouse_Age: health_insurance_lead.spouse_age,
      Spouse_Height_Feet: health_insurance_lead.spouse_height_feet,
      Spouse_Height_Inches: health_insurance_lead.spouse_height_inches,
      Spouse_Weight: health_insurance_lead.spouse_weight,
      Spouse_Tobacco_Use: health_insurance_lead.spouse_tobacco_use,
      Spouse_Preexisting_Conditions: health_insurance_lead.spouse_preexisting_conditions,
      Child_1_Gender: health_insurance_lead.child_1_gender,
      Child_1_Age: health_insurance_lead.child_1_age,
      Child_1_Height_Feet: health_insurance_lead.child_1_height_feet,
      Child_1_Height_Inches: health_insurance_lead.child_1_height_inches,
      Child_1_Weight: health_insurance_lead.child_1_weight,
      Child_1_Tobacco_Use: health_insurance_lead.child_1_tobacco_use,
      Child_1_Preexisting_Conditions: health_insurance_lead.child_1_preexisting_conditions,
      eHealth_url: health_insurance_lead.ehealth_url,
      leadid_token: health_insurance_lead.leadid_token,
      visitor_id: health_insurance_lead.visitor_id,
      TrustedForm_cert_url: health_insurance_lead.trusted_form_cert_url,
    }
    append_skip_dupe_check(params)
    params
  end

  def params_for_type_23
    params = {
      TYPE: MEDICARE_SUPPLEMENT_INSURANCE_TYPE,
      Test_Lead: health_insurance_lead.test_lead,
      Skip_XSL: health_insurance_lead.skip_xsl,
      Match_With_Partner_ID: health_insurance_lead.match_with_partner_id,
      Redirect_URL: health_insurance_lead.redirect_url,
      SRC: health_insurance_lead.src,
      Landing_Page: health_insurance_lead.landing_page,
      IP_Address: lead.visitor_ip,
      Sub_ID: health_insurance_lead.sub_id,
      Pub_ID: health_insurance_lead.pub_id,
      Optout: health_insurance_lead.optout,
      imbx: health_insurance_lead.imbx,
      Ref: health_insurance_lead.ref,
      user_agent: health_insurance_lead.user_agent,
      tsrc: health_insurance_lead.tsrc,
      First_Name: lead.first_name,
      Last_Name: lead.last_name,
      Address_1: lead.address_1,
      Address_2: lead.address_2,
      City: lead.city,
      State: lead.state,
      Zip: lead.zip,
      Phone_Number: lead.day_phone,
      Email_Address: lead.email,
      Bday: birth_date,
      Gender: lead.gender,
      Age: health_insurance_lead.age,
      eHealth_url: health_insurance_lead.ehealth_url,
      leadid_token: health_insurance_lead.leadid_token,
      visitor_id: health_insurance_lead.visitor_id,
      TrustedForm_cert_url: health_insurance_lead.trusted_form_cert_url,
    }
    append_skip_dupe_check(params)
    params
  end

  def birth_date
    lead.birth_date.strftime("%m/%d/%Y") if lead.birth_date
  end

  def perform_http_request(exclusive)
    HTTParty.get request_url,
                 query: generate(exclusive),
                 headers: request_header,
                 timeout: client.timeout
  end

  def append_skip_dupe_check(params)
    params.merge!(Skip_Dupe_Check: '1') if Settings.boberdoo_skip_dupe_check
  end

end
