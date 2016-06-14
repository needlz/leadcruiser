require 'rails_helper'

RSpec.describe PurchaseOrder, :type => :model do
  let(:purchase_order) { create(:purchase_order) }

  describe '#states_array' do
    describe 'if states presents' do
      it 'returns array of states' do
        expect(purchase_order.states_array).to eq ["Texas", "Colorado", "Washington"]
      end
    end

    describe 'if states blank' do
      let(:purchase_order) { create(:purchase_order, states: nil) }

      it 'returns empty string' do
        expect(purchase_order.states_array).to be_empty
      end
    end
  end

  describe '#states_array=' do
    it 'creates string of states' do
      new_states = ["California", "Utah", "Ohio"]

      expect{ purchase_order.states_array = new_states }.to change { purchase_order.states }
                                                            .to('Utah, Ohio')
    end
  end
end
