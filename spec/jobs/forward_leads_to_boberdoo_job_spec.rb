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

    let(:unprocessed_leads) { create_list(:lead, unprocessed_leads_count, :from_boberdoo, vertical: vertical) }

    before do
      processed_leads
      unprocessed_leads
    end

    context 'when in forwarding range' do
      let(:range_start) { (Time.current - 1.minutes) }

      before do
        day_name = Ranges.days[Time.current.wday]
        EditableConfiguration.global.update_attributes!("#{ day_name }_forwarding_range_start" => range_start,
                                                        "#{ day_name }_forwarding_range_end" => range_start + 20.minutes)
      end

      context 'when no responses from same client' do
        it 'forwards batch of leads' do
          pending
          expect_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order).exactly(unprocessed_leads_count).times
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
          allow(ForwardLeadsToBoberdooJob).to receive(:not_yet_forwarded_leads) { processed_leads }
        end

        it 'does not send request' do
          pending
          expect_any_instance_of(ForwardLeadsToBoberdooJob).to_not receive(:perform_for_lead_and_order)
          ForwardLeadsToBoberdooJob.new.perform
        end
      end

      context 'when response from another client created during job' do
        before do
          processed_leads.each do |lead|
            lead.responses.where(purchase_order_id: purchase_order.id).update_all(purchase_order_id: nil)
          end
          allow(ForwardLeadsToBoberdooJob).to receive(:not_yet_forwarded_leads) { processed_leads }
        end

        it 'sends requests' do
          pending
          expect_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order).exactly(processed_leads.count).times
          ForwardLeadsToBoberdooJob.new.perform
        end
      end
    end

    context 'when not in forwarding range' do
      let(:range_start) { (Time.now + 1.minutes) }

      before do
        day_name = Ranges.days[Time.current.wday]
        EditableConfiguration.global.update_attributes!("#{ day_name }_forwarding_range_start" => range_start,
                                                        "#{ day_name }_forwarding_range_end" => range_start + 20.minutes)
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

  describe '#leads_to_be_forwarded' do

    context 'when there are many unprocessed leads' do
      let!(:leads_count) { 1 }
      let!(:unprocessed_leads) { create_list(:lead, leads_count, :from_boberdoo, vertical: vertical) }

      it 'returns some of leads' do
        pending
        expect(ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.count).to eq ForwardLeadsToBoberdooJob.max_leads_per_batch
      end
    end

    context 'when there are few unprocessed leads' do
      let(:leads_count) { 1 }
      let!(:unprocessed_leads) { create_list(:lead, leads_count, :from_boberdoo, vertical: vertical) }

      it 'returns some of leads' do
        expect(ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.count).to eq leads_count
      end
    end
  end

  describe '#schedule' do
    context 'forwarding range is set' do
      let(:range_start) { (Time.current + 10.minutes) }

      before do
        day_name = Ranges.days[Time.current.wday]
        EditableConfiguration.global.update_attributes!("#{ day_name }_forwarding_range_start" => range_start,
                                                        "#{ day_name }_forwarding_range_end" => range_start + 10.minutes)
      end

      it 'schedules job' do
        expect { ForwardLeadsToBoberdooJob.schedule }.to enqueue_a(ForwardLeadsToBoberdooJob).be_within(2.seconds).of(range_start)
      end
    end

    context 'forwarding range is not set' do
      it 'do nothing' do

      end
    end
  end

end
