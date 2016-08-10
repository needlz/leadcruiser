require 'rails_helper'

RSpec.describe ForwardHealthInsuranceLead do

  let!(:vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
  let!(:boberdoo_client) { create(:clients_vertical, integration_name: ClientsVertical::BOBERDOO) }
  let!(:non_boberdoo_client) { create(:clients_vertical, integration_name: '') }
  let!(:boberdoo_client_order) { create(:purchase_order, vertical: vertical, client_id: boberdoo_client.id) }
  let!(:non_boberdoo_client_order) { create(:purchase_order, vertical: vertical, client_id: non_boberdoo_client.id) }
  let(:lead) { create(:lead) }

  describe '#perform' do
    before do
      allow_any_instance_of(RequestToClientGenerator).to receive(:send_data)
    end

    context 'during afterhours time' do
      before do
        default_year = Time.parse('2000-01-01')
        now = Time.current
        ForwardingTimeRange.afterhours.create!(begin_day: Date::DAYNAMES[now.wday],
                                               begin_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 1.minute,
                                               end_day: Date::DAYNAMES[(now.wday + 1) % 7],
                                               end_time: default_year.in_time_zone(-8).change(hour: now.hour, min: now.min) - 2.minutes)
      end

      it 'does not make request to Boberdoo' do
        expect(ForwardLeadToClientRequest).to receive(:new).once.and_call_original
        ForwardHealthInsuranceLead.perform(lead)
      end
    end

    context 'during non-afterhours time' do
      it 'does make request to Boberdoo' do
        expect(ForwardLeadToClientRequest).to receive(:new).twice.and_call_original
        ForwardHealthInsuranceLead.perform(lead)
      end
    end
  end

end
