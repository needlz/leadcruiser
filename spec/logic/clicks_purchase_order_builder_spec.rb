require 'rails_helper'

RSpec.describe ClicksPurchaseOrderBuilder, :type => :request do
  let!(:clients_vertical1) { create(:clients_vertical) }
  let!(:clients_vertical2) { create(:clients_vertical) }

  describe '#po_available_clients' do
    context 'if same prices' do
      let!(:vertical_1_clicks_order_1) { create(:clicks_purchase_order, page_id: 1, price: 10, clients_vertical_id: clients_vertical1.id) }
      let!(:vertical_1_clicks_order_2) { create(:clicks_purchase_order, page_id: 1, price: 10, clients_vertical_id: clients_vertical1.id) }
      let!(:vertical_2_clicks_order_1) { create(:clicks_purchase_order, page_id: 1, price: 10, clients_vertical_id: clients_vertical2.id) }
      let!(:vertical_2_clicks_order_2) { create(:clicks_purchase_order, page_id: 1, price: 10, clients_vertical_id: clients_vertical2.id) }

      it 'returns random purchase order with equal prices for each clients vertical' do
        result = ClicksPurchaseOrderBuilder.new.po_available_clients

        expect(result.length).to eq ClientsVertical.count
        expect([vertical_1_clicks_order_1, vertical_1_clicks_order_2]).to include result.first
        expect([vertical_2_clicks_order_1, vertical_2_clicks_order_2]).to include result.last
      end
    end

    context 'if different prices' do
      let!(:vertical_1_clicks_order) { create(:clicks_purchase_order, page_id: 1, price: 20, clients_vertical_id: clients_vertical1.id) }
      let!(:vertical_1_clicks_order_most_expensive) { create(:clicks_purchase_order, page_id: 1, price: 25, clients_vertical_id: clients_vertical1.id) }
      let!(:vertical_2_clicks_order_most_expensive) { create(:clicks_purchase_order, page_id: 1, price: 35, clients_vertical_id: clients_vertical2.id) }
      let!(:vertical_2_clicks_order) { create(:clicks_purchase_order, page_id: 1, price: 11, clients_vertical_id: clients_vertical2.id) }

      it 'returns purchase order with the highest price for each clients vertical' do
        result = ClicksPurchaseOrderBuilder.new.po_available_clients

        expect(result.length).to eq ClientsVertical.count
        expect(result).to eq [vertical_1_clicks_order_most_expensive, vertical_2_clicks_order_most_expensive]
      end
    end

    context 'if one of clients verticals has no purchase orders' do
      let!(:vertical_2_clicks_order_most_expensive) { create(:clicks_purchase_order, page_id: 1, price: 35, clients_vertical_id: clients_vertical2.id) }
      let!(:vertical_2_clicks_order) { create(:clicks_purchase_order, page_id: 1, price: 11, clients_vertical_id: clients_vertical2.id) }

      it 'skips this clients vertical' do
        result = ClicksPurchaseOrderBuilder.new.po_available_clients

        expect(result.length).to eq ClientsVertical.count - 1
        expect(result).to eq [vertical_2_clicks_order_most_expensive]
      end
    end

    context 'if there is no clients verticals' do
      it 'returns empty array' do
        ClientsVertical.delete_all

        result = ClicksPurchaseOrderBuilder.new.po_available_clients

        expect(result).to be_empty
      end
    end

    context 'if there is no purchase orders' do
      it 'returns empty array' do
        result = ClicksPurchaseOrderBuilder.new.po_available_clients

        expect(result).to be_empty
      end
    end
  end
end
