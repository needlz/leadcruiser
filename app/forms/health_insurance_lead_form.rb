class HealthInsuranceLeadForm

  attr_reader :params
  attr_accessor :lead, :health_insurance_lead

  def initialize(params)
    @params = params
  end

  def lead_attributes
    birth_date = params[:DOB] || params[:Bday]
    {
      session_hash: params[:session_hash],
      site_id: params[:site_id],
      form_id: params[:form_id],
      first_name: params[:First_Name],
      last_name: params[:Last_Name],
      address_1: params[:Address_1],
      address_2: params[:Address_2],
      city: params[:City],
      state: params[:State],
      zip: params[:Zip],
      day_phone: params[:Phone_Number],
      email: params[:Email_Address],
      birth_date: (Date.strptime(birth_date, "%m/%d/%Y") if birth_date),
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

end
