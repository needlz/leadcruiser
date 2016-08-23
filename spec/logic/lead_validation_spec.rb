require 'rails_helper'

RSpec.describe LeadValidation do
  describe '#duplicated_lead' do
    context 'if duplicated and has response' do
      let!(:lead) { create(:lead, status: 'sold') }
      let!(:response) { create(:response, lead: lead) }

      it 'returns true' do
        result = LeadValidation.duplicated_lead(lead.email, lead.vertical_id, lead.site_id)

        expect(result).to be_truthy
      end
    end

    context 'if duplicated and dont have response' do
      let!(:lead) { create(:lead, status: 'sold') }

      it 'returns false' do
        result = LeadValidation.duplicated_lead(lead.email, lead.vertical_id, lead.site_id)

        expect(result).to be_falsey
      end
    end

    context 'if not duplicated' do
      let!(:lead) { create(:lead, status: Lead::SOLD) }
      let(:other_lead) { { email: 'other_email', vertical_id: 2, site_id: 2, status: Lead::BLOCKED} }

      it 'returns false' do
        result = LeadValidation.duplicated_lead(other_lead[:email], other_lead[:vertical_id], other_lead[:site_id])

        expect(result).to be_falsey
      end
    end
  end

  describe '#blocked' do
    let!(:lead) { create(:lead, visitor_ip: '127.0.0.15') }

    context 'if blocked' do
      let!(:block_list) { create(:block_list, block_ip: lead.visitor_ip)}

      it 'returns true' do
        result = LeadValidation.blocked lead

        expect(result).to be_truthy
      end
    end

    context 'if not blocked' do
      it 'returns false' do
        result = LeadValidation.blocked lead

        expect(result).to be_falsey
      end
    end
  end
end
