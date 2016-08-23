require 'rails_helper'

RSpec.describe CreateHealthLead do

  let(:params) { params_for_health_lead }
  let(:form) { HealthInsuranceLeadForm.new(params) }
  let(:lead_creation) { CreateHealthLead.new(form) }

  before do
    create(:vertical, name: Vertical::HEALTH_INSURANCE)
    allow(ForwardHealthInsuranceLead).to receive(:perform)
  end

  describe '#perform' do
    it 'sends contact to SendGrid' do
      lead_creation.perform
      expect(AddSendgridContactJob).to have_been_enqueued
    end
  end

end
