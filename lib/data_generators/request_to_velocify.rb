class RequestToVelocify < RequestToClient

  LINK = ''

  VELOCIFY_CAMPAIGN_IDS = {
    RequestToBoberdoo::HEALTH_INSURANCE_TYPE => {
      'healthmatchup.com' => 33,
      'gethealthcare.co' => 31
    },
    RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE => {
        'healthmatchup.com' => 32,
        'gethealthcare.co' => 34
      },
  }

  Velocify.configure do |config|
    config.username = "promiseinsurance@five9.com"
    config.password = "2AP380nV"
  end

  attr_reader :health_insurance_lead

  def initialize(lead)
    @lead = lead
    @health_insurance_lead = lead.health_insurance_lead
  end

  def generate
    do_request true, lead.clients_verticals.last
  end

  def success?
    response[:response][:additions][:lead][:status][:message] == 'Success'
  end

  def rejection_reason
    response['error']
  end

  def campaign_id
    VELOCIFY_CAMPAIGN_IDS[health_insurance_lead.boberdoo_type][lead.site.domain]
  end

  private

  def perform_http_request(exclusive)
    velocify_lead = Velocify::Lead.new
    velocify_lead.campaign_id = campaign_id
    velocify_params.each do |field_name, field|
      velocify_lead.add_field id: field[:field_id], value: field[:value]
    end
    
    Velocify::Lead.add(leads: [velocify_lead])
  end

  def height_string(feet, inches)
    "#{ feet } ft #{ inches } in"
  end

  def velocify_params
    {
        First_Name: { field_id: 1, value: lead.first_name },
        Last_Name: { field_id: 2, value: lead.last_name },
        Phone_Number: { field_id: 3, value: lead.day_phone },
        Email_Address: { field_id: 7, value: lead.email },
        Address_1: { field_id: 8, value: lead.address_1 },
        City: { field_id: 9, value: lead.city },
        State: { field_id: 10, value: lead.state },
        Zip: { field_id: 11, value: lead.zip },
        Address_2: { field_id: 148, value: lead.address_2 },
        Gender: { field_id: 751, value: lead.gender },
        Height: { field_id: 757, value: height_string(health_insurance_lead.height_feet, health_insurance_lead.height_inches) },
        Weight: { field_id: 758, value: health_insurance_lead.weight },
        Tobacco_Use: { field_id: 759, value: health_insurance_lead.tobacco_use },
        Preexisting_Conditions: { field_id: 764, value: health_insurance_lead.preexisting_conditions },

        Spouse_Gender: { field_id: 769, value: health_insurance_lead.spouse_gender },
        Spouse_Weight: { field_id: 776, value: health_insurance_lead.spouse_weight },
        Spouse_Tobacco_Use: { field_id: 777, value: health_insurance_lead.spouse_tobacco_use },
        Spouse_Preexisting_Conditions: { field_id: 782, value: health_insurance_lead.spouse_preexisting_conditions },

        Child_1_Gender: { field_id: 798, value: health_insurance_lead.child_1_gender },
        Child_1_Height: { field_id: 803, value: height_string(health_insurance_lead.child_1_height_feet, health_insurance_lead.child_1_height_inches) },
        Child_1_Weight: { field_id: 804, value: health_insurance_lead.child_1_weight },
        Child_1_Tobacco_Use: { field_id: 805, value: health_insurance_lead.child_1_tobacco_use },
        Child_1_Preexisting_Conditions: { field_id: 809, value: health_insurance_lead.child_1_preexisting_conditions },

        Child_2_Gender: { field_id: 813, value: health_insurance_lead.child_2_gender },
        Child_2_Weight: { field_id: 819, value: health_insurance_lead.child_2_weight },
        Child_2_Tobacco_Use: { field_id: 820, value: health_insurance_lead.child_2_tobacco_use },
        Child_2_Preexisting_Conditions: { field_id: 824, value: health_insurance_lead.child_2_preexisting_conditions },

        Child_3_Gender: { field_id: 828, value: health_insurance_lead.child_3_gender },
        Child_3_Weight: { field_id: 834, value: health_insurance_lead.child_3_weight },
        Child_3_Tobacco_Use: { field_id: 835, value: health_insurance_lead.child_3_tobacco_use },
        Child_3_Preexisting_Conditions: { field_id: 840, value: health_insurance_lead.child_3_preexisting_conditions },

        Child_4_Gender: { field_id: 844, value: health_insurance_lead.child_4_gender },
        Child_4_Weight: { field_id: 850, value: health_insurance_lead.child_4_weight },
        Child_4_Tobacco_Use: { field_id: 851, value: health_insurance_lead.child_4_tobacco_use },
        Child_4_Preexisting_Conditions: { field_id: 855, value: health_insurance_lead.child_4_preexisting_conditions },
        Lead_ID: { field_id: 886, value: lead.id },
        Lead_Post_Info: { field_id: 929, value: "ip: #{ lead.visitor_ip } imbx: #{ health_insurance_lead.imbx }" },
        Age: { field_id: 946, value: health_insurance_lead.age },
        Spouse_Age: { field_id: 947, value: health_insurance_lead.spouse_age },
        Sub_ID: { field_id: 948, value: health_insurance_lead.sub_id },
        Date_Created: { field_id: 949, value: health_insurance_lead.created_at.strftime("%m/%d/%Y") },
        Household_Income: { field_id: 961, value: health_insurance_lead.household_income },
        SRC: { field_id: 1097, value: health_insurance_lead.src },
    }
  end

end
