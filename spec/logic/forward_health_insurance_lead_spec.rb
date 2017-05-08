require 'rails_helper'

RSpec.describe ForwardHealthInsuranceLead do
  let!(:vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
  let!(:boberdoo_client) { create(:clients_vertical, integration_name: ClientsVertical::BOBERDOO) }
  let!(:icd_client) { create(:clients_vertical, integration_name: 'insurance_care_direct') }
  let!(:boberdoo_client_order) { create(:purchase_order, vertical: vertical, client_id: boberdoo_client.id) }
  let!(:icd_purchase_order) { create(:purchase_order, vertical: vertical, client_id: icd_client.id) }
  let(:lead) { create(:lead, vertical: vertical) }
  let(:health_insurance_lead_med_supp) { create(:health_insurance_lead,
                                                lead: lead,
                                                boberdoo_type: RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE) }
  let(:health_insurance_lead_health) { create(:health_insurance_lead,
                                              lead: lead,
                                              boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE) }

  describe '#perform' do
    describe 'Boberdoo afterhours handling' do
      before do
        health_insurance_lead_health
        allow_any_instance_of(RequestToClient).to receive(:do_request)
      end

      context 'during afterhours time' do
        before do
          now = Time.current
          ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                                 begin_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 1.minute,
                                                 end_day: Date::DAYNAMES[(now.wday + 1) % 7],
                                                 end_time: ForwardingTimeRange::DEFAULT_YEAR.change(hour: now.hour, min: now.min) - 2.minutes)
        end

        it 'does not make request to Boberdoo' do
          expect(ForwardLeadToClientRequest).to_not receive(:new)
          ForwardHealthInsuranceLead.perform(lead)
        end
      end # during afterhours time

      context 'during non-afterhours time' do
        it 'does make request to Boberdoo' do
          expect(ForwardLeadToClientRequest).to receive(:new).once.and_call_original
          ForwardHealthInsuranceLead.perform(lead)
        end
      end # during non-afterhours time
    end # Boberdoo afterhours handling

    context 'when lead comes from HMU' do
      before do
        health_insurance_lead.update_attributes!(src: 'HealthMatchup')
      end

      context 'when lead is healthcare' do
        let!(:health_insurance_lead) { health_insurance_lead_health }

        it 'forwards lead to ICD' do
          expect(Vertical.health_insurance.purchase_orders.active).to include(icd_purchase_order)
          expect_any_instance_of(RequestToInsuranceCareDirect).to receive(:do_request).and_call_original
          ForwardHealthInsuranceLead.perform(lead)
        end

        it 'forwards lead to Boberdoo with source attribute "HealthMatchup2"' do
          pending
          expect_any_instance_of(RequestToBoberdoo).to receive(:do_request).and_call_original
          ForwardHealthInsuranceLead.perform(lead)
        end
      end # when lead is healthcare

      context 'when lead is medicare' do
        let!(:health_insurance_lead) { health_insurance_lead_med_supp }

        it 'does not forward lead to ICD' do
          expect_any_instance_of(RequestToInsuranceCareDirect).to_not receive(:do_request).and_call_original
          ForwardHealthInsuranceLead.perform(lead)
        end

        it 'forwards lead to Boberdoo with default source attribute' do
          pending
          expect_any_instance_of(RequestToBoberdoo).to receive(:do_request).and_call_original
          ForwardHealthInsuranceLead.perform(lead)
        end
      end # when lead is medicare
    end # when lead comes from HMU
  end # #perform

end
