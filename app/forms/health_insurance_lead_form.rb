class HealthInsuranceLeadForm

  attr_reader :params
  attr_accessor :lead, :health_insurance_lead

  def initialize(params)
    @params = params
  end

  def lead_attributes
    {
      session_hash: params[:session_hash],
      site_id: params[:site_id],
      form_id: params[:form_id],
      first_name: params[:First_Name],
      last_name: params[:Last_Name],
      address_1: params[:Assress_1],
      address_2: params[:Address_2],
      city: params[:City],
      state: params[:State],
      zip: params[:Zip],
      day_phone: params[:Phone_Number],
      email: params[:Emil_Address],
      birth_date: Date.strptime(params[:dob], "%m/%d/%Y"),
      gender: params[:Gender],
      vertical_id: Vertical.health_insurance.id,
      visitor_ip: params[:IP_Address]
    }
  end

  def health_insurance_lead_attributes
    {
      boberdoo_type: params[:TYPE],
      match_with_partner_id: params[:Match_With_Partner_ID],
      skip_xsl: params[:Skip_XSL],
      test_lead: params[:Test_Lead],
      redirect_url: params[:Redirect_URL],
      src: params[:SRC],
      sub_id: params[:Sub_ID],
      pub_id: params[:Pub_ID],
      optout: params[:Optout],
      imbx: params[:imbx],
      ref: params[:Ref],
      user_agent: params[:user_agent],
      tsrc: params[:tsrc],
      landing_page: params[:Landing_Page],

      fpl: params[:FPL],
      age: params[:Age],
      height_feet: params[:Height_Feet],
      height_inches: params[:Height_Inches],
      weight: params[:Weight],
      tobacco_use: params[:Tobacco_Use],
      preexisting_conditions: params[:Preexisting_Conditions],

      household_income: params[:Household_Income],
      household_size: params[:Household_Size],
      qualifying_life_event: params[:Qualifying_Life_Event],
      spouse_gender: params[:Spouse_Gender],
      spouse_age: params[:Spouse_Age],
      spouse_height_feet: params[:Spouse_Height_Feet],
      spouse_height_inches: params[:Spouse_Height_Inches],
      spouse_weight: params[:Spouse_Weight],
      spouse_tobacco_use: params[:Spouse_Tobacco_Use],
      spouse_preexisting_conditions: params[:Spouse_Preexisting_Conditions],

      child_1_gender: params[:Child_1_Gender],
      child_1_age: params[:Child_1_Age],
      child_1_height_feet: params[:Child_1_Height_Feet],
      child_1_height_inches: params[:Child_1_Height_Inches],
      child_1_weight: params[:Child_1_Weight],
      child_1_tobacco_use: params[:Child_1_Tobacco_Use],
      child_1_preexisting_conditions: params[:Child_1_Preexisting_Conditions],

      child_2_gender: params[:Child_2_Gender],
      child_2_age: params[:Child_2_Age],
      child_2_height_feet: params[:Child_2_Height_Feet],
      child_2_height_inches: params[:Child_2_Height_Inches],
      child_2_weight: params[:Child_2_Weight],
      child_2_tobacco_use: params[:Child_2_Tobacco_Use],
      child_2_preexisting_conditions: params[:Child_2_Preexisting_Conditions],

      child_3_gender: params[:Child_3_Gender],
      child_3_age: params[:Child_3_Age],
      child_3_height_feet: params[:Child_3_Height_Feet],
      child_3_height_inches: params[:Child_3_Height_Inches],
      child_3_weight: params[:Child_3_Weight],
      child_3_tobacco_use: params[:Child_3_Tobacco_Use],
      child_3_preexisting_conditions: params[:Child_3_Preexisting_Conditions],

      child_4_gender: params[:Child_4_Gender],
      child_4_age: params[:Child_4_Age],
      child_4_height_feet: params[:Child_4_Height_Feet],
      child_4_height_inches: params[:Child_4_Height_Inches],
      child_4_weight: params[:Child_4_Weight],
      child_4_tobacco_use: params[:Child_4_Tobacco_Use],
      child_4_preexisting_conditions: params[:Child_4_Preexisting_Conditions],
    }
  end

  def boberdoo_params
    {
      TYPE: health_insurance_lead.boberdoo_type,
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
      FPL: health_insurance_lead.fpl,
      DOB: health_insurance_lead.birth_date,
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
    }
  end

end
