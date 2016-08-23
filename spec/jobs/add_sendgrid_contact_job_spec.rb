require 'rails_helper'

RSpec.describe AddSendgridContactJob, type: :job do

  let(:lead) { create(:lead) }
  let(:job) { AddSendgridContactJob.new }

  describe '#perform' do
    it 'calls AddSendgridContact' do
      expect_any_instance_of(AddSendgridContact).to receive(:perform)
      job.perform(lead.id)
    end
  end

end
