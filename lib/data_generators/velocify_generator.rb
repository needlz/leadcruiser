class VelocifyGenerator < ClientRequestGenerator

  LINK = ''

  attr_reader :health_insurance_lead

  def initialize(lead)
    @lead = lead
    @health_insurance_lead = lead.health_insurance_lead
  end

  def generate
    {
      First_Name: lead.first_name,
      Last_Name: lead.last_name,
      Phone_Number: lead.last_name,
      Email_Address: lead.email,
      Address_1: lead.address_1,
      City: lead.city,
      State: lead.state,
      Zip: lead.zip,
      Address_2: lead.address_2,
      Gender: lead.gender,
      Height: height_string(health_insurance_lead.height_feet, health_insurance_lead.height_inches),
      Weight: health_insurance_lead.weight,
      Tobacco_Use: health_insurance_lead.tobacco_use,
      Preexisting_Conditions: health_insurance_lead.preexisting_conditions,
      Spouse_Gender: health_insurance_lead.spouse_gender,
      Spouse_Weight: health_insurance_lead.spouse_weight,
      Spouse_Tobacco_Use: health_insurance_lead.spouse_tobacco_use,
      Spouse_Preexisting_Conditions: health_insurance_lead.spouse_preexisting_conditions,
      Child_1_Gender: health_insurance_lead.child_1_gender,
      # Child_1_DOB: health_insurance_lead.child_1_dob,
      Child_1_Height: height_string(health_insurance_lead.child_1_height_feet, health_insurance_lead.child_1_height_inches),
      Child_1_Weight: health_insurance_lead.child_1_weight,
      Child_1_Tobacco_Use: health_insurance_lead.child_1_tobacco_use,
      Child_1_Preexisting_Conditions: health_insurance_lead.child_1_preexisting_conditions,

      Child_2_Gender: health_insurance_lead.child_2_gender,
      Child_2_Weight: health_insurance_lead.child_2_weight,
      Child_2_Tobacco_Use: health_insurance_lead.child_2_tobacco_use,
      Child_2_Preexisting_Conditions: health_insurance_lead.child_2_preexisting_conditions,

      Child_3_Gender: health_insurance_lead.child_3_gender,
      Child_3_Weight: health_insurance_lead.child_3_weight,
      Child_3_Tobacco_Use: health_insurance_lead.child_3_tobacco_use,
      Child_3_Preexisting_Conditions: health_insurance_lead.child_3_preexisting_conditions,

      Child_4_Gender: health_insurance_lead.child_4_gender,
      Child_4_Weight: health_insurance_lead.child_4_weight,
      Child_4_Tobacco_Use: health_insurance_lead.child_4_tobacco_use,
      Child_4_Preexisting_Conditions: health_insurance_lead.child_4_preexisting_conditions,
      Lead_Post_Info: "ip: #{ lead.visitor_ip } imbx: #{ health_insurance_lead.imbx }",
      Age: health_insurance_lead.age,
      Spouse_Age: health_insurance_lead.spouse_age,
      Sub_ID: health_insurance_lead.sub_id,
      Date_Created: health_insurance_lead.created_at.strftime("%m/%d/%Y"),
      Household_Income: health_insurance_lead.household_income,
      SRC: health_insurance_lead.src,
    }
  end

  private

  def perform_http_request(exclusive)
    HTTParty.post request_url,
                  query: generate,
                  timeout: client.timeout
  end

  def height_string(feet, inches)
    "#{ feet } ft #{ inches } in"
  end

end
