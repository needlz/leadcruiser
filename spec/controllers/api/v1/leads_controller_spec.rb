require 'rails_helper'
require 'api_helper'

describe API::V1::LeadsController, type: :request do

  let (:message) do
    "Thanks for submitting your information!<br />Check your email for quotes and exciting offers for [pets_name]."
  end
  let(:session_hash) { '#234-22' }
  let!(:vertical) { create(:vertical, name: Vertical::PET_INSURANCE) }
  let!(:health_vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
  let!(:clients_vertical) { create(:clients_vertical, vertical_id: vertical.id) }
  let!(:purchase_order) { create(:purchase_order, vertical_id: health_vertical.id, client_id: clients_vertical.id) }
  let(:correct_data) { {first_name: 'John',
                         last_name: 'Doe',
                         session_hash: session_hash,
                         vertical_id: vertical.id,
                         site_id: 1,
                         zip: 10004,
                         day_phone: '2-12-22',
                         email: 'test@example.com',
                         visitor_ip: Faker::Internet.ip_v4_address } }
  let(:pet_data) { {species: 'cat',
                     spayed_or_neutered: 'false',
                     pet_name: 'kitty',
                     breed: 'sphinx',
                     birth_month: 12,
                     birth_year: 1998,
                     gender: 'male',
                     conditions: false} }
  let(:wrong_data) { correct_data.except(:first_name) }
  let(:wrong_pet_data) { {species: '',
                           spayed_or_neutered: '',
                           pet_name: '',
                           breed: '',
                           birth_month: 12,
                           birth_year: 1998,
                           gender: '',
                           conditions: false} }
  let(:data_with_sold_state) { correct_data.merge({status: 'sold'}) }
  let(:city) { 'New York' }
  let(:state) { 'NY' }
  let(:hit) { create(:hit, id: 1) }
  let(:site) { create(:site, domain: 'gethealthcare.co') }

  describe '#create with visitor' do
    before do
      stub_request(:get, "https://api.smartystreets.com/zipcode?auth-id=&auth-token=&zipcode=10004").
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
        to_return(status: 200, body: [{ city_states: [{ state_abbreviation: state, city: city }] }].to_json,
                  headers: {'Content-Type' => 'application/json'})
    end

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
    before do
      stub_request(:get, "https://api.smartystreets.com/zipcode?auth-id=&auth-token=&zipcode=10004").
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
        to_return(status: 200, body: [{ city_states: [{ state_abbreviation: state, city: city }] }].to_json,
                  headers: {'Content-Type' => 'application/json'})
    end

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
    before do
      allow_any_instance_of(RequestToClient).to receive(:do_request)
    end

    let(:site) { create(:site) }
    let (:params) {
      params_for_health_lead(site_id: site.id)
    }
    let(:lead_result) {
      {
        session_hash: "session hash",
        site_id: site.id,
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
        birth_date: Date.strptime('12/23/1980', '%m/%d/%Y').in_time_zone,
        gender:"Male",
        vertical_id: health_vertical.id,
        visitor_ip: "75.2.92.149"
      }
    }

    let(:health_insurance_lead_result) {
      {
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
        ehealth_url: 'http://www.ehealthinsurance.com/111',
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
      }
    }

    it 'creates correct lead' do
      expect{ api_post 'leads', params }.to change { Lead.count}.from(0).to(1)
      expect(Lead.last.attributes.symbolize_keys).to include (lead_result)
    end

    it 'creates test lead' do
      GethealthcareHit.delete_all

      params[:Phone_Number] = '78700000' + hit.id.to_s
      params[:First_Name] = 'test'
      params[:Last_Name] = 'test'
      params[:Email_Address] = 'test@test.com'
      params[:Address_1] = 'test'

      api_post 'leads', params
      expect( GethealthcareHit.last.lead ).to eq Lead.last
    end

    it 'creates correct health insurance lead' do
      expect{ api_post 'leads', params }.to change { HealthInsuranceLead.count }.from(0).to(1)

      new_health_insurance_lead = HealthInsuranceLead.last

      expect(new_health_insurance_lead.attributes.symbolize_keys).to include (health_insurance_lead_result)
    end

    describe 'validations' do
      before do
        clients_vertical.update_attributes!(vertical_id: vertical.id)
        purchase_order = PurchaseOrder.create!(client_id: clients_vertical.id)
        allow_any_instance_of(SendPetDataWorker).to receive(:perform) do |sender, lead_id|
          Response.create!(lead_id: lead_id,
                           purchase_order: purchase_order,
                           client_name: clients_vertical.integration_name)
        end
      end

      it 'grants that ip is not blocked' do
        BlockList.create(block_ip: params[:IP_Address], active: true)
        api_post 'leads', params
        expect(Lead.last.status).to eq(Lead::BLOCKED)
      end

      it 'grants that first and last names are not test' do
        api_post 'leads', params.merge(First_Name: Lead::TEST_TERM, Last_Name: Lead::TEST_TERM)
        expect(Lead.last.status).to eq(Lead::BLOCKED)
        expect(Lead.last.disposition).to eq(Lead::TEST_NO_SALE)
      end

      it 'grants that there are no profanities in name and email' do
        api_post 'leads', params.merge(First_Name: 'ass', Last_Name: 'name')
        expect(Lead.last.status).to eq(Lead::BLOCKED)
        expect(Lead.last.disposition).to eq(Lead::PROFANITY)
      end

    end
  end

  describe '#create with type 23' do
    before do
      allow_any_instance_of(RequestToClient).to receive(:do_request)
    end

    let (:params) {
      params_for_medsupp_lead(site_id: site.id)
    }
    let(:lead_result) {
      {
        session_hash: "session hash",
        site_id: site.id,
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
        birth_date: Date.strptime('12/23/1980', '%m/%d/%Y').in_time_zone,
        gender:"Male",
        vertical_id: health_vertical.id,
        visitor_ip: "75.2.92.149"
      }
    }

    let(:health_insurance_lead_result) {
      {
        boberdoo_type: "23",
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
        age: 5,
      }
    }

    it 'creates correct lead' do
      expect{ api_post 'leads', params }.to change { Lead.count}.from(0).to(1)
      expect(Lead.last.attributes.symbolize_keys).to include (lead_result)
    end

    it 'creates test lead' do
      GethealthcareHit.delete_all

      params[:Phone_Number] = '78700000' + hit.id.to_s
      params[:First_Name] = 'test'
      params[:Last_Name] = 'test'
      params[:Email_Address] = 'test@test.com'
      params[:Address_1] = 'test'

      api_post 'leads', params
      expect( GethealthcareHit.last.lead ).to eq Lead.last
    end

    it 'creates correct health insurance lead' do
      expect{ api_post 'leads', params }.to change { HealthInsuranceLead.count }.from(0).to(1)

      new_health_insurance_lead = HealthInsuranceLead.last

      expect(new_health_insurance_lead.attributes.symbolize_keys).to include (health_insurance_lead_result)
    end

    context 'when request to Boberdoo needed' do
      before do
        EditableConfiguration.create!
        clients_vertical.update_attributes!(integration_name: ClientsVertical::BOBERDOO)
      end

      context 'during non-forwarding time range' do
        before do
          day_name = Date::DAYNAMES[Time.current.wday]
          ForwardingTimeRange.create!(begin_day: day_name,
                                      begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: Time.current.in_time_zone(ForwardingTimeRange::TIME_ZONE).hour,
                                                                                                                             min: Time.current.in_time_zone(ForwardingTimeRange::TIME_ZONE).min) - 10.minutes,
                                      end_day: day_name,
                                      end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: Time.current.in_time_zone(ForwardingTimeRange::TIME_ZONE).hour,
                                                                                                                           min: Time.current.in_time_zone(ForwardingTimeRange::TIME_ZONE).min) + 10.minutes,
                                      kind: 'afterhours')
        end

        it 'does not schedule request to Boberdoo' do
          expect_any_instance_of(ForwardLeadToClientRequest).to_not receive(:perform)
          api_post 'leads', params
        end
      end

      context 'during forwarding time range' do
        it 'schedules request to Boberdoo' do
          expect_any_instance_of(ForwardLeadToClientRequest).to receive(:perform)
          api_post 'leads', params
        end
      end
    end

    describe 'validations' do
      before do
        clients_vertical.update_attributes!(vertical_id: vertical.id)
        purchase_order = PurchaseOrder.create!(client_id: clients_vertical.id)
        allow_any_instance_of(SendPetDataWorker).to receive(:perform) do |sender, lead_id|
          Response.create!(lead_id: lead_id,
                           purchase_order: purchase_order,
                           client_name: clients_vertical.integration_name)
        end
      end

      it 'grants that ip is not blocked' do
        BlockList.create(block_ip: params[:IP_Address], active: true)
        api_post 'leads', params
        expect(Lead.last.status).to eq(Lead::BLOCKED)
      end

      it 'grants that first and last names are not test' do
        api_post 'leads', params.merge(First_Name: Lead::TEST_TERM, Last_Name: Lead::TEST_TERM)
        expect(Lead.last.status).to eq(Lead::BLOCKED)
        expect(Lead.last.disposition).to eq(Lead::TEST_NO_SALE)
      end

    end
  end

  describe 'creation of pet insurance lead' do
    before do
      stub_request(:get, "https://api.smartystreets.com/zipcode?auth-id=&auth-token=&zipcode=10004").
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
        to_return(status: 200, body: [{ city_states: [{ state_abbreviation: state, city: city }] }].to_json,
                  headers: {'Content-Type' => 'application/json'})
    end

    let(:client) { ClientsVertical.create!(vertical_id: vertical.id,
                                           integration_name: "vet_care_health",
                                           active: true,
                                           exclusive: true,
                                           service_url: "http://www.vetcarehealth.com/getquote/postlead",
                                           display: true) }
    let(:client_2) { ClientsVertical.create!(vertical_id: vertical.id,
                                           integration_name: "client 2",
                                           active: true,
                                           exclusive: true,
                                           service_url: "http://www.vetcarehealth.com/getquote/postlead",
                                           display: true) }
    let(:client_3) { ClientsVertical.create!(vertical_id: vertical.id,
                                           integration_name: "client 3",
                                           active: true,
                                           exclusive: true,
                                           service_url: "http://www.vetcarehealth.com/getquote/postlead",
                                           display: true) }


    it 'queries state and cite of provided zipcode from api.smartystreets.com' do
      api_post 'leads', lead: correct_data, pet: pet_data

      lead = Lead.last
      expect(lead.city).to eq city
      expect(lead.state).to eq state
    end

    context "when got successful responses from at least one client" do
      let!(:purchase_order) { PurchaseOrder.create!(vertical_id: vertical.id,
                                                   exclusive: false,
                                                   price: 1,
                                                   active: true,
                                                   leads_count_sold: 100,
                                                   client_id: client.id) }
      let!(:purchase_order_2) { PurchaseOrder.create!(vertical_id: vertical.id,
                                                   exclusive: false,
                                                   price: 1,
                                                   active: true,
                                                   leads_count_sold: 100,
                                                   client_id: client_2.id) }
      let!(:purchase_order_3) { PurchaseOrder.create!(vertical_id: vertical.id,
                                                   exclusive: false,
                                                   price: 1,
                                                   active: true,
                                                   leads_count_sold: 100,
                                                   client_id: client_3.id) }
      let(:tracking_page) { create(:tracking_page) }
      let!(:clicks_order_2) { create(:clicks_purchase_order,
                                     page_id: tracking_page.id,
                                     price: 10,
                                     clients_vertical_id: client.id) }
      let!(:clicks_order_2) { create(:clicks_purchase_order,
                                     page_id: tracking_page.id,
                                     price: 10,
                                     clients_vertical_id: client_2.id) }
      let!(:clicks_order_3) { create(:clicks_purchase_order,
                                     page_id: tracking_page.id,
                                     price: 10,
                                     clients_vertical_id: client_3.id) }
      before do
        allow_any_instance_of(SendPetDataWorker).to receive(:perform) do |sender, lead_id|
          Response.create!(lead_id: lead_id,
                           purchase_order: purchase_order,
                           client_name: client.integration_name)
          Response.create!(lead_id: lead_id,
                           purchase_order: purchase_order,
                           client_name: client_2.integration_name,
                           rejection_reasons: 'no')
          Response.create!(lead_id: lead_id,
                           purchase_order: purchase_order,
                           client_name: client_3.integration_name,
                           rejection_reasons: 'no')
        end
      end

      it 'sends email to product owner' do
        expect(SendEmailWorker).to receive(:perform_async)
        api_post 'leads', lead: correct_data, pet: pet_data
      end

      it 'returns list with other clients' do
        api_post 'leads', lead: correct_data, pet: pet_data
        json = JSON.parse(response.body)

        expect(json['success']).to eq true
        expect(json['client']).to eq [controller.send(:client_to_json, client).to_json].to_json
        expect(json['other_client']).to eq [controller.send(:client_of_order_to_json, clicks_order_2).to_json,
                                            controller.send(:client_of_order_to_json, clicks_order_3).to_json].to_json
      end
    end

    context "when got failed responses from all clients" do
      let(:client) { ClientsVertical.create!(vertical_id: vertical.id,
                                              integration_name: "vet_care_health",
                                              active: true,
                                              exclusive: true,
                                              service_url: "http://www.vetcarehealth.com/getquote/postlead",
                                              display: true) }
      let(:purchase_order) { PurchaseOrder.create!(vertical_id: vertical.id,
                                                   exclusive: false,
                                                   price: 1,
                                                   active: true,
                                                   leads_count_sold: 100,
                                                   client_id: client.id) }

      before do
        allow_any_instance_of(SendPetDataWorker).to receive(:perform) do |sender, lead_id|
          Response.create!(lead_id: lead_id,
                           purchase_order: purchase_order,
                           client_name: client.integration_name,
                           rejection_reasons: 'failure')
        end
      end

      it 'sends email to product owner' do
        expect(SendEmailWorker).to_not receive(:perform_async)
        api_post 'leads', lead: correct_data, pet: pet_data
      end
    end

    describe 'validations' do
      before do
        purchase_order = PurchaseOrder.create!(client_id: clients_vertical.id)
        allow_any_instance_of(SendPetDataWorker).to receive(:perform) do |sender, lead_id|
          Response.create!(lead_id: lead_id,
                           purchase_order: purchase_order,
                           client_name: clients_vertical.integration_name)
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

      it 'grants ip is not blocked' do
        BlockList.create(block_ip: correct_data[:visitor_ip], active: true)
        api_post 'leads', lead: correct_data, pet: pet_data
        expect(Lead.last.status).to eq(Lead::BLOCKED)
      end

      it 'grants first and last names are not test' do
        api_post 'leads',
                 lead: correct_data.merge(first_name: Lead::TEST_TERM, last_name: Lead::TEST_TERM),
                 pet: pet_data
        expect(Lead.last.status).to eq(Lead::BLOCKED)
        expect(Lead.last.disposition).to eq(Lead::TEST_NO_SALE)
      end

      it 'grants there is no profanity in email' do
        profanity_email = 'ass@example.com'
        api_post 'leads',
                 lead: correct_data.merge(email: profanity_email),
                 pet: pet_data
        expect(Lead.last.status).to eq(Lead::BLOCKED)
        expect(Lead.last.disposition).to eq(Lead::PROFANITY)
      end

      it 'grants lead is not test sale' do
        api_post 'leads',
                 lead: correct_data.merge(first_name: "Erik", last_name: 'Needham'),
                 pet: pet_data
        expect(Lead.last.disposition).to eq(Lead::TEST_SALE)
      end

    end
  end

end
