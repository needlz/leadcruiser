require 'rails_helper'

RSpec.describe HealthInsuranceLeadForm do

  let!(:vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
  let(:form) { HealthInsuranceLeadForm.new(params) }

  describe '#lead_attributes' do

    context 'when lead is health insurance' do
      let(:params) { params_for_health_lead }

      context 'when params are valid' do
        it 'creates lead with generated attributes' do
          expect{ Lead.create(form.lead_attributes) }.to_not raise_error
        end
      end

      context 'when Date Of Birth is empty' do
        let(:params) { params_for_health_lead.merge(DOB: '') }

        it 'creates lead with generated attributes' do
          expect{ Lead.create(form.lead_attributes) }.to_not raise_error
        end
      end
    end

    context 'when lead is medicare supplement insurance' do
      let(:params) { params_for_medsupp_lead }

      context 'when params are valid' do
        it 'creates lead with generated attributes' do
          expect{ Lead.create(form.lead_attributes) }.to_not raise_error
        end
      end

      context 'when Date Of Birth is empty' do
        let(:params) { params_for_medsupp_lead.merge(Bday: '') }

        it 'creates lead with generated attributes' do
          expect{ Lead.create(form.lead_attributes) }.to_not raise_error
        end
      end
    end

  end

end
