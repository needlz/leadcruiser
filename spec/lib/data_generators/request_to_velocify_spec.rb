require 'rails_helper'
require 'data_generators/request_to_boberdoo'

RSpec.describe RequestToVelocify, type: :request do
  let(:health_match_up) { create(:site, domain: 'healthmatchup.com') }
  let(:get_health) { create(:site, domain: 'gethealthcare.co') }
  let(:health_insurance_lead_med_supp) { create(:health_insurance_lead,
                                                lead: lead,
                                                boberdoo_type: RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE) }
  let(:health_insurance_lead_health) { create(:health_insurance_lead,
                                              lead: lead,
                                              boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE) }
  let(:client) { create(:clients_vertical) }

  describe '#do_request' do
    context 'when lead from site healthmatchup.com' do
      let(:lead) { create(:lead, site: health_match_up) }

      context 'lead of type 23' do
        before do
          health_insurance_lead_med_supp
        end

        it 'uses campaign id 32' do
          request = RequestToVelocify.new(lead)
          expect(request.campaign_id).to eq 32
        end
      end

      context 'when lead of type 21' do
        before do
          health_insurance_lead_health
        end

        it 'uses campaign id 33' do
          request = RequestToVelocify.new(lead)
          expect(request.campaign_id).to eq 33
        end
      end
    end

    context 'when lead from site gethealthcare.co' do
      let(:lead) { create(:lead, site: get_health) }

      context 'lead of type 23' do
        before do
          health_insurance_lead_med_supp
        end

        it 'uses campaign id 31' do
          request = RequestToVelocify.new(lead)
          expect(request.campaign_id).to eq 31
        end
      end

      context 'when lead of type 21' do
        before do
          health_insurance_lead_health
        end

        it 'uses campaign id 34' do
          request = RequestToVelocify.new(lead)
          expect(request.campaign_id).to eq 34
        end
      end
    end

  end
end
