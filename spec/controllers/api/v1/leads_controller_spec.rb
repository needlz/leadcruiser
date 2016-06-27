require 'rails_helper'
require 'api_helper'

describe API::V1::LeadsController, type: :request do

  let (:message) do
    "Thanks for submitting your information!<br />Check your email for quotes and exciting offers for [pets_name]."
  end
  let (:session_hash) { '#234-22' }
  let! (:vertical) { create(:vertical, name: Vertical::PET_INSURANCE) }
  let! (:clients_vertical) { create(:clients_vertical, vertical_id: vertical.id) }
  let (:correct_data) { {first_name: 'John',
                         last_name: 'Doe',
                         session_hash: session_hash,
                         vertical_id: vertical.id,
                         site_id: 1,
                         city: 'New York',
                         state: 'NY',
                         zip: 10004,
                         day_phone: '2-12-22',
                         email: 'test@example.com'} }
  let (:pet_data) { {species: 'cat',
                     spayed_or_neutered: 'false',
                     pet_name: 'kitty',
                     breed: 'sphinx',
                     birth_month: 12,
                     birth_year: 1998,
                     gender: 'male',
                     conditions: false} }
  let (:wrong_data) { correct_data.except(:first_name) }
  let (:wrong_pet_data) { {species: '',
                           spayed_or_neutered: '',
                           pet_name: '',
                           breed: '',
                           birth_month: 12,
                           birth_year: 1998,
                           gender: '',
                           conditions: false} }
  let (:data_with_sold_state) { correct_data.merge({status: 'sold'}) }

  before do
    stub_request(:get, "https://api.smartystreets.com/zipcode?auth-id=&auth-token=&zipcode=10004").
        with(:headers => {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200, :body => [{city_states: [{state_abbreviation: 'NY', city: 'New York'}]}].to_json, :headers => {})
  end

  describe '#create with visitor' do
    let! (:visitor) { Visitor.create(session_hash: session_hash) }

    it 'returns success' do
      result = api_post 'leads', lead: correct_data, pet: pet_data

      expect(result['errors']).to eq message.gsub('[pets_name]', pet_data[:pet_name])
    end

    it 'creates lead with session_hash' do
      expect { api_post 'leads', lead: correct_data, pet: pet_data }.to change { Lead.count }.from(0).to(1)

      expect(Lead.last.session_hash).to eq session_hash
    end

    it 'creates lead with city and state' do
      api_post 'leads', lead: correct_data, pet: pet_data

      expect(Lead.where(city: 'New York', state: 'NY').exists?).to eq(true)
    end

    it 'creates pet' do
      api_post 'leads', lead: correct_data, pet: pet_data

      expect(DetailsPet.where(breed: 'sphinx').exists?).to eq(true)
    end
  end

  describe '#create without mandatory field' do
    it 'returns error without vertical_id' do
      result = api_post 'leads', lead: wrong_data, pet: pet_data

      expect(result['errors']).to eq message.gsub('[pets_name]', pet_data[:pet_name])
    end

    it 'returns all errors for mandatory fields' do
      api_post 'leads', lead: wrong_data, pet: wrong_pet_data
      result = JSON.parse response.body

      expect(result['errors']).to eq message.gsub('[pets_name]', wrong_pet_data[:pet_name])
    end

    it 'does not create lead without vertical_id' do
      api_post 'leads', lead: wrong_data, pet: pet_data

      expect(Visitor.count).to eq(0)
    end

  end

  describe '#create with type 21' do
    let! (:vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
    let (:params) { {
        session_hash: 'session hash',
        site_id: '1',
        form_id: '1',
        TYPE: '21',
        Test_Lead: '1',
        Skip_XSL: '1',
        Match_With_Partner_ID: '22.456',
        Redirect_URL: 'http://www.yoursite.com/',
        SRC: 'test',
        Landing_Page: 'landing',
        IP_Address: '75.2.92.149',
        Sub_ID: '12',
        Pub_ID: '12345',
        Optout: 'Optout',
        imbx: 'imbx',
        Ref: 'Ref',
        user_agent: 'user_agent',
        tsrc: 'tsrc',
        First_Name: 'John',
        Last_Name: 'Doe',
        Address_1: 'Address_1',
        Address_2: 'Address_2',
        City: 'Chicago',
        State: 'IL',
        Zip: '60610',
        Phone_Number: '3125554811',
        Email_Address: 'test@nags.us',
        FPL: '<138%M',
        DOB: '12/23/1980',
        Gender: 'Male',
        Age: '5',
        Height_Feet: '12',
        Height_Inches: '12',
        Weight: '8',
        Tobacco_Use: 'Yes',
        Preexisting_Conditions: 'Yes',
        Household_Income: '6',
        Household_Size: '6',
        Qualifying_Life_Event: 'Lost/Losing Coverage',
        Spouse_Gender: 'Male',
        Spouse_Age: '8',
        Spouse_Height_Feet: '12',
        Spouse_Height_Inches: '8',
        Spouse_Weight: '11',
        Spouse_Tobacco_Use: 'Yes',
        Spouse_Preexisting_Conditions: 'Yes',
        Child_1_Gender: 'Male',
        Child_1_Age: '6',
        Child_1_Height_Feet: '10',
        Child_1_Height_Inches: '6',
        Child_1_Weight: '8',
        Child_1_Tobacco_Use: 'Yes',
        Child_1_Preexisting_Conditions:'Yes',
        Child_2_Gender: 'Male',
        Child_2_Age: '8',
        Child_2_Height_Feet: '11',
        Child_2_Height_Inches: '7',
        Child_2_Weight: '4',
        Child_2_Tobacco_Use: 'Yes',
        Child_2_Preexisting_Conditions:'Yes',
        Child_3_Gender: 'Male',
        Child_3_Age: '9',
        Child_3_Height_Feet: '9',
        Child_3_Height_Inches: '9',
        Child_3_Weight: '9',
        Child_3_Tobacco_Use: 'Yes',
        Child_3_Preexisting_Conditions:'Yes',
        Child_4_Gender: 'Male',
        Child_4_Age: '12',
        Child_4_Height_Feet: '15',
        Child_4_Height_Inches: '15',
        Child_4_Weight: '7',
        Child_4_Tobacco_Use: 'Yes',
        Child_4_Preexisting_Conditions:'Yes'
    } }
    let(:lead_result) { {
        session_hash: "session hash",
        site_id: 1,
        form_id: 1,
        first_name: "John",
        last_name: "Doe",
        address_1: "Address_1",
        address_2: 'Address_2',
        city: "Chicago",
        state: "IL",
        zip: "60610",
        day_phone: "3125554811",
        email: "test@nags.us",
        birth_date: Date.strptime('12/23/1980', '%m/%d/%Y'),
        gender:"Male",
        vertical_id: 1,
        visitor_ip: "75.2.92.149"
    } }

    let(:health_insurance_lead_result) { {
      boberdoo_type: "21",
      match_with_partner_id: "22.456",
      skip_xsl: "1",
      test_lead: "1",
      redirect_url: "http://www.yoursite.com/",
      src: "test",
      sub_id: "12",
      pub_id: "12345",
      optout: "Optout",
      imbx: "imbx",
      ref: "Ref",
      user_agent: "user_agent",
      tsrc: "tsrc",
      landing_page: "landing",
      fpl: "<138%M",
      age: 5,
      height_feet: 12,
      height_inches: 12,
      weight: 8,
      tobacco_use: "Yes",
      preexisting_conditions: "Yes",
      household_income: 6,
      household_size: 6,
      qualifying_life_event: "Lost/Losing Coverage",
      spouse_gender: "Male",
      spouse_age: 8,
      spouse_height_feet: 12,
      spouse_height_inches: 8,
      spouse_weight: 11,
      spouse_tobacco_use: "Yes",
      spouse_preexisting_conditions: "Yes",
      child_1_gender: "Male",
      child_1_age: 6,
      child_1_height_feet: 10,
      child_1_height_inches: 6,
      child_1_weight: 8,
      child_1_tobacco_use: "Yes",
      child_1_preexisting_conditions: "Yes",
      child_2_gender: "Male",
      child_2_age: 8,
      child_2_height_feet: 11,
      child_2_height_inches: 7,
      child_2_weight: 4,
      child_2_tobacco_use: "Yes",
      child_2_preexisting_conditions: "Yes",
      child_3_gender: "Male",
      child_3_age: 9,
      child_3_height_feet: 9,
      child_3_height_inches: 9,
      child_3_weight: 9,
      child_3_tobacco_use: "Yes",
      child_3_preexisting_conditions: "Yes",
      child_4_gender: "Male",
      child_4_age: 12,
      child_4_height_feet: 15,
      child_4_height_inches: 15,
      child_4_weight: 7,
      child_4_tobacco_use: "Yes",
      child_4_preexisting_conditions: "Yes"
    } }

    it 'should create correct lead' do
      expect{ api_post 'leads', params }.to change { Lead.count}.from(0).to(1)

      new_lead = Lead.last

      expect(new_lead.attributes.symbolize_keys).to include (lead_result)
    end

    it 'grant uniqueness of lead email' do
      expect(ForwardHealthInsuranceLead).to receive(:perform).once
      expect{ api_post 'leads', params }.to change { Lead.count}.from(0).to(1)
      expect(Lead.last.status).to be_nil
      expect{ api_post 'leads', params }.to change { Lead.count}.from(1).to(2)
      expect(Lead.last.status).to eq (Lead::DUPLICATED)
    end

    it 'should create correct health insurance lead' do
      expect{ api_post 'leads', params }.to change { HealthInsuranceLead.count}.from(0).to(1)

      new_health_insurance_lead = HealthInsuranceLead.last

      expect(new_health_insurance_lead.attributes.symbolize_keys).to include (health_insurance_lead_result)
    end
  end

  describe 'validation on lead uniqueness' do
    let (:another_pet_data) { { species: 'cat',
                                spayed_or_neutered: 'false',
                                pet_name: 'Mediolan',
                                breed: 'Cymric',
                                birth_month: 12,
                                birth_year: 1998,
                                gender: 'male',
                                conditions: false } }
    let (:sensitive_case_pet_data) { { species: 'cat',
                                       spayed_or_neutered: 'false',
                                       pet_name: 'MediOlan',
                                       breed: 'Cymric',
                                       birth_month: 12,
                                       birth_year: 1998,
                                       gender: 'male',
                                       conditions: false } }
    let (:response) { create(:response) }

    it 'sets duplicated status if the same lead was sold' do
      api_post 'leads', lead: data_with_sold_state, pet: pet_data

      Lead.last.sold!
      response.update_attributes(lead_id: Lead.last.id)

      api_post 'leads', lead: data_with_sold_state, pet: pet_data

      expect(Lead.last.status).to eq(Lead::DUPLICATED)
    end
  end

end
