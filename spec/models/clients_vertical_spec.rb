require 'rails_helper'

RSpec.describe ClientsVertical, :type => :model do

  describe 'refresh queue' do
    let(:clients_vertical) { create(:clients_vertical) }
    let(:vertical) { create(:vertical) }

    it 'changes verticals next clients to nil' do
      client = clients_vertical
      vertical_instance = vertical
      client.update_attributes(vertical: vertical_instance)

      expect{ client.refresh_queue }.to change { client.vertical.next_client }.from('Yurii').to(nil)
    end
  end

  describe 'display name' do
    let(:clients_vertical) { create(:clients_vertical) }

    it 'shows integration name' do
      client = clients_vertical

      expect( client.display_name ).to eq clients_vertical.integration_name
    end
  end

  describe 'validations' do
    let(:clients_vertical) { create(:clients_vertical) }

    it 'validates value of lead_forwarding_delay_seconds' do
      expect { clients_vertical.update_attributes!(lead_forwarding_delay_seconds: -1) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { clients_vertical.update_attributes!(lead_forwarding_delay_seconds: 0) }.to_not raise_error
      expect { clients_vertical.update_attributes!(lead_forwarding_delay_seconds: 1) }.to_not raise_error
    end
  end

end
