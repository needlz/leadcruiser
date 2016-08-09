require 'rails_helper'

RSpec.describe ForwardLeadsToBoberdooJob, type: :job do
  let(:vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
  let!(:client) { create(:clients_vertical, vertical: vertical, integration_name: ClientsVertical::BOBERDOO) }
  let!(:purchase_order) { create(:purchase_order, vertical: vertical, client_id: client.id) }

  before do
    EditableConfiguration.create!(forwarding_interval_minutes: 5)
  end

  describe '#perform' do
    let(:unprocessed_leads_count) { 3 }
    let(:processed_leads) {
      leads = create_list(:lead, 2, :from_boberdoo, vertical: vertical)
      leads.each do |lead|
        lead.responses << Response.create!(purchase_order: purchase_order)
      end
      leads
    }
    let(:now) { Time.current }

    let(:unprocessed_leads) { create_list(:lead, unprocessed_leads_count, :from_boberdoo, vertical: vertical) }

    before do
      processed_leads
      unprocessed_leads
    end

    context 'when in forwarding range' do
      let(:range_start) { (Time.current - 1.minutes) }

      before do
        ForwardingTimeRange.forwarding.create!(begin_day: Date::DAYNAMES[now.wday],
                                               begin_time: range_start,
                                               end_day: Date::DAYNAMES[(now.wday + 1) % 7],
                                               end_time: range_start + 20.minutes)
      end

      context 'when no responses from same client' do
        it 'forwards batch of leads' do
          expect_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order).exactly(ForwardLeadsToBoberdooJob.leads_per_batch).times
          ForwardLeadsToBoberdooJob.new.perform
        end

        it 'reschedules itself' do
          allow_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order)
          expect { ForwardLeadsToBoberdooJob.new.perform }.to enqueue_a(ForwardLeadsToBoberdooJob).
            be_within(2.seconds).of(Time.current + EditableConfiguration.global.forwarding_interval_minutes.minutes)
        end

        context 'when error occured during a request' do
          before do
            allow_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order) { raise StandardError }
          end

          it 'reschedules itself' do
            expect_any_instance_of(ForwardLeadToClientRequest).to_not receive(:perform)
            expect { ForwardLeadsToBoberdooJob.new.perform }.to enqueue_a(ForwardLeadsToBoberdooJob).
              be_within(2.seconds).of(Time.current + EditableConfiguration.global.forwarding_interval_minutes.minutes)
          end
        end
      end

      context 'when response from same client created during job' do
        before do
          allow(ForwardLeadsToBoberdooJob).to receive(:not_yet_forwarded_leads) { Lead.with_responses }
        end

        it 'does not send request' do
          expect_any_instance_of(ForwardLeadsToBoberdooJob).to_not receive(:perform_for_lead_and_order)
          ForwardLeadsToBoberdooJob.new.perform
        end
      end

      context 'when response from another client created during job' do
        before do
          processed_leads.each do |lead|
            lead.responses.where(purchase_order_id: purchase_order.id).update_all(purchase_order_id: nil)
          end
          allow(ForwardLeadsToBoberdooJob).to receive(:not_yet_forwarded_leads) { Lead.with_responses }
        end

        it 'sends requests' do
          expect_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order).exactly(ForwardLeadsToBoberdooJob.leads_per_batch).times
          ForwardLeadsToBoberdooJob.new.perform
        end
      end
    end

    context 'when not in forwarding range' do
      let(:range_start) { (Time.now + 1.minutes) }

      before do
        day_name = Date::DAYNAMES[Time.current.wday]
        ForwardingTimeRange.create!(kind: 'forwarding',
                                    begin_day: day_name,
                                    begin_time: range_start,
                                    end_day: day_name,
                                    end_time: range_start + 20.minutes)
      end

      it 'does not reschedule itself' do
        expect { ForwardLeadsToBoberdooJob.new.perform }.to_not enqueue_a(ForwardLeadsToBoberdooJob)
      end

      it 'does not forward batch of leads' do
        expect_any_instance_of(ForwardLeadsToBoberdooJob).to_not receive(:perform_for_lead_and_order).exactly(unprocessed_leads_count).times
        ForwardLeadsToBoberdooJob.new.perform
      end
    end

    context 'when forwarding range not set' do
      it 'does not reschedule itself' do
        expect { ForwardLeadsToBoberdooJob.new.perform }.to_not enqueue_a(ForwardLeadsToBoberdooJob)
      end

      it 'does not forward batch of leads' do
        expect_any_instance_of(ForwardLeadsToBoberdooJob).to_not receive(:perform_for_lead_and_order).exactly(unprocessed_leads_count).times
        ForwardLeadsToBoberdooJob.new.perform
      end
    end
  end

  describe '#not_yet_forwarded_leads' do
    context 'when there are few unprocessed leads' do
      let(:leads_count) { 3 }
      let!(:unprocessed_leads) { create_list(:lead, leads_count, :from_boberdoo, vertical: vertical) }

      it 'returns all unprocessed leads' do
        expect(ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.count).to eq leads_count
      end
    end
  end

  describe '#schedule' do
    context 'forwarding range is set' do
      let(:range_start) { (Time.current + 10.minutes) }
      let(:range_end) { (Time.current + 20.minutes) }

      before do
        date = Time.parse('2000-1-1')
        ForwardingTimeRange.create!(kind: 'forwarding',
                                    begin_day: Date::DAYNAMES[range_start.wday],
                                    begin_time: date.in_time_zone(-8).change(hour: range_start.hour, min: range_start.min),
                                    end_day: Date::DAYNAMES[range_end.wday],
                                    end_time: date.in_time_zone(-8).change(hour: range_end.hour, min: range_end.min))
      end

      it 'schedules job' do
        expect { ForwardLeadsToBoberdooJob.schedule }.to enqueue_a(ForwardLeadsToBoberdooJob).be_within(1.minute).of(range_start)
      end
    end
  end

  describe '#leads_per_batch' do
    let(:range_hours_length) { 2 }
    let(:range_mins_length) { 3 }
    let(:range_duration_mins) { (range_hours_length * 60 + range_mins_length) }
    let(:interval_mins) { 5 }
    let(:leads_count) { 500 }
    before do
      date = Time.parse('2000-1-1')
      ForwardingTimeRange.create!(kind: 'forwarding',
                                  begin_day: Date::DAYNAMES[(Time.current.wday + 1) % 7],
                                  begin_time: date.in_time_zone(-8).change(hour: 0, min: 0),
                                  end_day: Date::DAYNAMES[(Time.current.wday + 1) % 7],
                                  end_time: date.in_time_zone(-8).change(hour: range_hours_length, min: range_mins_length))

      EditableConfiguration.global.update_attributes!(forwarding_interval_minutes: interval_mins)
      allow(ForwardLeadsToBoberdooJob).to receive(:not_yet_forwarded_leads) { Array.new(leads_count) }
    end

    it 'returns count of leads to be sent in next request' do
      expect(ForwardLeadsToBoberdooJob.leads_per_batch).to eq (leads_count.to_f / (range_duration_mins.to_f / interval_mins).ceil)
    end
  end

end
