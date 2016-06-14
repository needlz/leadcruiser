require 'rails_helper'
require 'api_helper'

describe API::V1::ClientsController, type: :request do
  describe 'Get available clients'  do
    let (:clients_vertical) { create(:clients_vertical) }
    let (:clicks_purchase_order) { create(:clicks_purchase_order) }
    let (:tracking_page) { create(:tracking_page) }

    it 'return error message if no available clients' do
      ERROR_MESSAGE = 'No available clients'

      expect(ClientsVertical.count).to be_zero

      result = api_post 'clients'

      expect(result['errors']).to eq ERROR_MESSAGE
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns clients if available clients' do
      clicks_purchase_order.clients_vertical = clients_vertical
      clicks_purchase_order.tracking_page = tracking_page
      clicks_purchase_order.save

      result = api_post 'clients'

      expect(result['success']).to eq true
      expect(response).to have_http_status(:created)
      expect(result['clients']).to be_present
    end
  end
end
