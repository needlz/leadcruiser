require 'rails_helper'

RSpec.describe HealthInsuranceLead, type: :model do

  describe 'validations' do
    let(:required_attributes) {
      {
        boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE,
        src: 'gethealthcare',
        landing_page: '1',
        age: '50'
      }
    }

    it 'validate presence of :boberdoo_type, :src, :landing_page, :age' do
      HealthInsuranceLead.create!(required_attributes)
      required_attributes.keys.each do |required_attribute|
        attributes = required_attributes.except(required_attribute)
        expect { HealthInsuranceLead.create!(attributes) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#lead_type' do
    context 'when lead is medicare' do
      let(:lead) { create(:health_insurance_lead, boberdoo_type: RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE) }

      it 'returns name of medicare type' do
        expect(lead.lead_type).to eq 'Medicare Supplement'
      end
    end

    context 'when lead is health insurance' do
      let(:lead) { create(:health_insurance_lead, boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE) }

      it 'returns name of health insurance type' do
        expect(lead.lead_type).to eq 'Health Insurance'
      end
    end
  end

end
