require 'rails_helper'
require 'data_generators/request_to_boberdoo'

RSpec.describe RequestToBoberdoo, type: :request do
  let(:lead) { FactoryBot.create(:lead,
                      :from_boberdoo,
                      gender: 'Female') }

  it 'returns lead given during instantiation' do
    generator = RequestToBoberdoo.new(lead)
    expect(generator.lead).to eq(lead)
  end

  describe '#generate' do
    context 'for health leads' do
      let(:health_insurance_lead) { FactoryBot.create(:health_insurance_lead,
                                           lead: lead,
                                           boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE,
                                           age: 55) }

      it 'generates parameters to be sent to Boberdoo' do
        health_insurance_lead
        generator = RequestToBoberdoo.new(lead)

        expect(generator.generate(true)).to be_present
      end

      it 'generates parameters from lead' do
        health_insurance_lead
        boberdoo_params = RequestToBoberdoo.new(lead).generate(true)

        expect(boberdoo_params[:First_Name]).to eq lead.first_name
        expect(boberdoo_params[:Last_Name]).to eq lead.last_name
        expect(boberdoo_params[:Zip]).to eq lead.zip
        expect(boberdoo_params[:Phone_Number]).to eq lead.day_phone
        expect(boberdoo_params[:City]).to eq lead.city
        expect(boberdoo_params[:State]).to eq lead.state
        expect(boberdoo_params[:DOB]).to eq lead.birth_date.strftime("%m/%d/%Y")
      end

      it 'generates parameters from health insurance lead' do
        health_insurance_lead
        boberdoo_params = RequestToBoberdoo.new(lead).generate(true)

        expect(boberdoo_params[:TYPE]).to eq health_insurance_lead.boberdoo_type
        expect(boberdoo_params[:SRC]).to eq health_insurance_lead.src
        expect(boberdoo_params[:Landing_Page]).to eq health_insurance_lead.landing_page
        expect(boberdoo_params[:Age]).to eq health_insurance_lead.age
        expect(boberdoo_params[:leadid_token]).to eq health_insurance_lead.leadid_token
        expect(boberdoo_params[:eHealth_url]).to eq health_insurance_lead.ehealth_url
        expect(boberdoo_params[:leadid_token]).to eq health_insurance_lead.leadid_token
        expect(boberdoo_params[:visitor_id]).to eq health_insurance_lead.visitor_id
        expect(boberdoo_params[:TrustedForm_cert_url]).to eq health_insurance_lead.trusted_form_cert_url
      end

      context 'birth date is nil' do
        before do
          lead.update_attributes!(birth_date: nil)
        end

        context 'when lead is of type 21' do
          before do
            health_insurance_lead
          end

          it 'returns nil for Bday field' do
            boberdoo_params = RequestToBoberdoo.new(lead).generate(true)
            expect(boberdoo_params[:Bday]).to be_nil
          end
        end
      end

      it 'appends skip_dupe_check param to request' do
        Settings.boberdoo_skip_dupe_check = true
        health_insurance_lead
        request = RequestToBoberdoo.new(lead)
        params = request.generate(true)
        expect(params[:Skip_Dupe_Check]).to eq '1'

        Settings.boberdoo_skip_dupe_check = false
        params = request.generate(true)
        expect(params[:Skip_Dupe_Check]).to eq nil
      end
    end

    context 'for MedSupp leads' do
      let(:health_insurance_lead) { FactoryBot.create(:health_insurance_lead,
                                           lead: lead,
                                           boberdoo_type: RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE,
                                           age: 55) }

      it 'generates parameters to be sent to Boberdoo' do
        health_insurance_lead
        generator = RequestToBoberdoo.new(lead)

        expect(generator.generate(true)).to be_present
      end

      it 'generates parameters from lead' do
        health_insurance_lead
        boberdoo_params = RequestToBoberdoo.new(lead).generate(true)

        expect(boberdoo_params[:First_Name]).to eq lead.first_name
        expect(boberdoo_params[:Last_Name]).to eq lead.last_name
        expect(boberdoo_params[:Zip]).to eq lead.zip
        expect(boberdoo_params[:Phone_Number]).to eq lead.day_phone
        expect(boberdoo_params[:City]).to eq lead.city
        expect(boberdoo_params[:State]).to eq lead.state
        expect(boberdoo_params[:Gender]).to eq lead.gender
        expect(boberdoo_params[:Bday]).to eq lead.birth_date.strftime("%m/%d/%Y")
      end

      it 'generates parameters from health insurance lead' do
        health_insurance_lead
        boberdoo_params = RequestToBoberdoo.new(lead).generate(true)

        expect(boberdoo_params[:TYPE]).to eq health_insurance_lead.boberdoo_type
        expect(boberdoo_params[:SRC]).to eq health_insurance_lead.src
        expect(boberdoo_params[:Landing_Page]).to eq health_insurance_lead.landing_page
        expect(boberdoo_params[:Age]).to eq health_insurance_lead.age
        expect(boberdoo_params[:eHealth_url]).to eq health_insurance_lead.ehealth_url
        expect(boberdoo_params[:leadid_token]).to eq health_insurance_lead.leadid_token
        expect(boberdoo_params[:visitor_id]).to eq health_insurance_lead.visitor_id
        expect(boberdoo_params[:TrustedForm_cert_url]).to eq health_insurance_lead.trusted_form_cert_url
      end

      context 'birth date is nil' do
        before do
          lead.update_attributes!(birth_date: nil)
        end

        context 'when lead is of type 23' do
          before do
            health_insurance_lead
          end

          it 'returns nil for DOB field' do
            boberdoo_params = RequestToBoberdoo.new(lead).generate(true)
            expect(boberdoo_params[:DOB]).to be_nil
          end
        end

      end # birth date is nil
    end # for MedSupp leads
  end # generate

  describe '#source' do
    let(:icd){ FactoryBot.create(:clients_vertical, integration_name: ClientsVertical::ICD) }

    context 'SRC is HealthMatchup' do
      let!(:health_insurance_lead) { FactoryBot.create(:health_insurance_lead,
                                           lead: lead,
                                           boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE,
                                           age: 55, src: 'HealthMatchup') }

      context 'there was successful response from ICD' do
        let!(:response_fomr_iCD) { FactoryBot.create(:transaction_attempt,
                                                      client_id: icd.id,
                                                      lead_id: lead.id) }

        it 'returns HealthMatchup2' do
          request = RequestToBoberdoo.new(lead)
          expect(lead.health_insurance_lead.src).to be_present
          expect(request.generate(true)[:SRC]).to eq('HealthMatchup2')
        end
      end

      context 'there was no successful response from ICD' do
        let!(:response_fomr_iCD) { FactoryBot.create(:response,
                                                      client_name: ClientsVertical::ICD,
                                                      rejection_reasons: 'reasons',
                                                      lead_id: lead.id) }

        it 'returns original source' do
          request = RequestToBoberdoo.new(lead)
          expect(lead.health_insurance_lead.src).to be_present
          expect(request.generate(true)[:SRC]).to eq(lead.health_insurance_lead.src)
        end
      end
    end

    context 'SRC is not HealthMatchup' do
      let!(:health_insurance_lead) { FactoryBot.create(:health_insurance_lead,
                                            lead: lead,
                                            boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE,
                                            age: 55, src: 'gethealthcare') }

      it 'returns original source' do
        request = RequestToBoberdoo.new(lead)
        expect(lead.health_insurance_lead.src).to be_present
        expect(request.generate(true)[:SRC]).to eq(lead.health_insurance_lead.src)
      end
    end
  end
end
