require 'rails_helper'
require 'api_helper'

describe API::V1::ClicksController, type: :request do

  describe 'POST #create' do
    let(:clients_vertical) { create(:clients_vertical) }
    let(:full_click_params) {
      { click:
          { visitor_ip: 'ip',
            clients_vertical_id: clients_vertical.id,
            clicks_purchase_order_id: 1,
            site_id: 1,
            page_id: 1,
            partner_id: 1 }
      }
    }

    context 'when visitor_ip and clients_vertical_id present' do
      context 'when page_id present' do
        pending
      end

      context 'when page_id missing' do
        let(:click_params) { full_click_params.deep_merge(click: { page_id: nil }) }

        context 'when clicks_purchase_order present' do
          context 'when valid clicks_purchase_order' do
            before do
              ClicksPurchaseOrder.create!(
                clients_vertical_id: clients_vertical.id
              )
            end

            it 'sets click status to SOLD' do
              result = api_post(:clicks, click_params)
              expect(response).to have_http_status(:created)
              expect(result['message']).to eq 'Click was captured successfully'
              expect(Click.last.sold?).to be_truthy
            end
          end

          context 'when invalid clicks_purchase_order' do
            before do
              ClicksPurchaseOrder.create!(
                clients_vertical_id: clients_vertical.id,
                total_count: 2,
                total_limit: 1
              )
            end

            it 'returns error message' do
              result = api_post(:clicks, click_params)
              expect(response).to have_http_status(:unprocessable_entity)
              expect(result['errors']).to eq 'No purchase orders for this client'
            end
          end
        end

        context 'when clicks_purchase_order missing' do
          it 'returns error message' do
            result = api_post(:clicks, click_params)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(result['errors']).to eq 'No purchase orders for this client'
          end
        end
      end
    end

    context 'when visitor_ip or clients_vertical_id missing' do
      let(:click_params) { full_click_params.deep_merge(click: { visitor_ip: nil, clients_vertical_id: nil }) }

      it 'returns validation error' do
        result = api_post(:clicks, click_params)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(result['errors']).to eq ["Visitor ip cannot be blank", "Clients vertical cannot be blank"]
      end
    end
  end

end
