require 'rails_helper'

RSpec.describe Lead, :type => :model do
  let(:lead){ create(:lead) }

  describe '#latest_response' do
    let!(:response){ create(:response, lead_id: lead.id) }
    let!(:last_response){ create(:response, lead_id: lead.id) }

    it 'returns latest response' do
      expect(lead.latest_response).to eq last_response
    end
  end

  describe '#sold_responses' do
    let!(:sold_response1){ create(:response, price: 2, lead_id: lead.id) }
    let!(:sold_response2){ create(:response, lead_id: lead.id) }
    let!(:not_sold_response){ create(:response, price: nil, lead_id: lead.id) }

    it 'returns all with prices' do
      expect(lead.sold_responses).to match_array [sold_response1, sold_response2]
    end

    it 'returns all responses ordered' do
      expect(lead.sold_responses).to eq [sold_response2, sold_response1]
    end
  end

  describe 'client_sold_to' do
    let!(:vertical) { create(:vertical) }
    let!(:clients_vertical) { create(:clients_vertical, vertical_id: vertical.id) }

    it 'returns clients vertical' do
      lead.update_attributes(vertical: vertical)

      expect(lead.client_sold_to clients_vertical.integration_name).to eq clients_vertical
    end
  end

  describe '#sold_po_price' do
    describe 'if no purchase order with such id' do
      let(:wrong_po_id){ -1 }

      it 'returns zero' do
        expect(lead.sold_po_price wrong_po_id).to eq Lead::ZERO_PRICE
      end
    end

    describe 'if no purchase order with such id' do
      let!(:purchase_order){ create(:purchase_order) }

      it 'returns price of po' do
        expect(lead.sold_po_price purchase_order.id).to eq Lead::PRICE_PRECISION % purchase_order.price.to_f
      end
    end
  end

  describe '#sold_type'  do
    let!(:transaction_attempt){ create(:transaction_attempt, lead_id: lead.id) }

    it 'returns successful transaction attempt' do
      expect(lead.sold_type).to eq transaction_attempt
    end
  end

  describe '#name' do
    it 'returns concatenated first nad last name' do
      lead.update_attributes!(first_name: '1', last_name: '2')
      expect(lead.name).to eq '1 2'
    end
  end
end
