require 'rails_helper'
require 'api_helper'

describe API::V1::ClientsController, type: :request do
  describe 'Get available clients'  do
    let (:vertical) { create(:vertical) }
    let (:clients_vertical) { create(:clients_vertical, vertical_id: vertical.id) }
    let (:clicks_purchase_order) { create(:clicks_purchase_order) }
    let (:tracking_page) { create(:tracking_page) }

    it 'return error message if no available clients' do
      error_message = 'No available clients'

      expect(ClientsVertical.count).to be_zero

      result = api_post 'clients', vertical_id: vertical.id

      expect(result['errors']).to eq error_message
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns clients if available clients' do
      clicks_purchase_order.clients_vertical = clients_vertical
      clicks_purchase_order.tracking_page = tracking_page
      clicks_purchase_order.save

      result = api_post 'clients', vertical_id: vertical.id

      expect(result['success']).to eq true
      expect(response).to have_http_status(:created)
      expect(result['clients']).to be_present
    end
  end
end
