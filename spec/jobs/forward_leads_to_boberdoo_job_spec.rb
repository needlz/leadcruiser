require 'rails_helper'

RSpec.describe ForwardLeadsToBoberdooJob, type: :job do
  let(:vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
  let!(:purchase_order) { create(:purchase_order, vertical: vertical) }
  let(:client) { create(:client, vertical: vertical) }

  before do
    EditableConfiguration.create!
  end


  describe '#perform' do
    let(:unprocessed_leads_count) { 3 }
    let(:processed_leads) {
      leads = create_list(:lead, 2, :from_boberdoo, vertical: vertical)
      leads.each do |lead|
        lead.responses << Response.create!()
      end
      leads
    }

    let(:unprocessed_leads) { create_list(:lead, unprocessed_leads_count, :from_boberdoo, vertical: vertical) }

    before do
      processed_leads
      unprocessed_leads
    end

    context 'when in forwarding range' do
      let(:range_start) { (Time.now - 1.minutes).change(usec: 0) }

      before do
        EditableConfiguration.global.update_attributes!(forwarding_range_start: range_start, forwarding_range_end: range_start + 20.minutes)
      end

      it 'forwards batch of leads' do
        expect_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order).exactly(unprocessed_leads_count).times
        ForwardLeadsToBoberdooJob.new.perform
      end

      it 'reschedules itself' do
        allow_any_instance_of(ForwardLeadsToBoberdooJob).to receive(:perform_for_lead_and_order)
        expect { ForwardLeadsToBoberdooJob.new.perform }.to enqueue_a(ForwardLeadsToBoberdooJob).to_run_at((Time.current + ForwardLeadsToBoberdooJob::INTERVAL).change(usec: 0))
      end
    end

    context 'when forwarding range not set' do
      it 'reschedules itself' do
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
      let(:leads_count) { ForwardLeadsToBoberdooJob.max_leads_per_batch * 2 }
      let!(:unprocessed_leads) { create_list(:lead, leads_count, :from_boberdoo, vertical: vertical) }

      it 'returns some of leads' do
        expect(ForwardLeadsToBoberdooJob.leads_to_be_forwarded.count).to eq ForwardLeadsToBoberdooJob.max_leads_per_batch
      end
    end

    context 'when there are few unprocessed leads' do
      let(:leads_count) { ForwardLeadsToBoberdooJob.max_leads_per_batch / 2 }
      let!(:unprocessed_leads) { create_list(:lead, leads_count, :from_boberdoo, vertical: vertical) }

      it 'returns some of leads' do
        expect(ForwardLeadsToBoberdooJob.leads_to_be_forwarded.count).to eq leads_count
      end
    end
  end

  describe '#schedule' do
    context 'forwarding range is set' do
      let(:range_start) { (Time.current + 10.minutes).change(usec: 0) }

      before do
        EditableConfiguration.global.update_attributes!(forwarding_range_start: range_start, forwarding_range_end: range_start + 10.minutes)
      end

      it 'schedules job' do
        expect { ForwardLeadsToBoberdooJob.schedule }.to enqueue_a(ForwardLeadsToBoberdooJob).to_run_at(range_start)
      end
    end

    context 'forwarding range is not set' do
      it 'do nothing' do

      end
    end
  end

end
