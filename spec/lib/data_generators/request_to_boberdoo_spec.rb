require 'rails_helper'
require 'data_generators/request_to_boberdoo'

RSpec.describe RequestToBoberdoo, type: :request do
  let(:lead) { create(:lead, :for_boberdoo) }
  let(:health_insurance_lead) { create(:health_insurance_lead, lead: lead, boberdoo_type: '21') }

  it 'returns lead given during instantiation' do
    generator = RequestToBoberdoo.new(lead)
    expect(generator.lead).to eq(lead)
  end

  describe '#generate' do
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

      context 'when lead is of type 21' do
        before do
          create(:health_insurance_lead, lead: lead, boberdoo_type: '23')
        end

        it 'returns nil for Bday field' do
          boberdoo_params = RequestToBoberdoo.new(lead).generate(true)
          expect(boberdoo_params[:Bday]).to be_nil
        end
      end
    end
  end
end
