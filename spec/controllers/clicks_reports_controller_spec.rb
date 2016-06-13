require 'rails_helper'

RSpec.describe ClicksReportsController, :type => :controller do
  render_views

  describe '#index' do
    it 'returns success' do
      get :index
      expect(response).to be_success
    end

    context 'when requesting html format' do
      it 'renders template' do
        get :index, format: 'html'
        expect(response).to render_template(:index)
      end
    end

    context 'when requesting js format' do
      it 'renders template' do
        xhr :get, :index, format: 'js'
        expect(response).to render_template(:index)
      end
    end

    context 'when requesting xls format' do
      it 'is successful' do
        get :index, format: 'xls'
        expect(response).to be_success
      end

      it 'returns file' do
        expect(@controller).to receive(:send_data)
        get :index, format: 'xls'
        expect(response.header['Content-Type']).to eq('application/xls; charset=utf-8')
      end
    end
  end

  describe '#by_client' do
    let(:clients_vertical) { create(:clients_vertical) }

    it 'returns success' do
      get :by_client, clients_vertical_id: clients_vertical.id
      expect(response).to have_http_status(:success)
    end

    context 'when requesting html format' do
      it 'renders template' do
        get :by_client, clients_vertical_id: clients_vertical.id, format: 'html'
        expect(response).to render_template(:by_client)
      end
    end

    context 'when requesting js format' do
      it 'renders template' do
        xhr :get, :by_client, clients_vertical_id: clients_vertical.id, format: 'js'
        expect(response).to render_template(:by_client)
      end
    end

    context 'when requesting xls format' do
      it 'is successful' do
        get :by_client, clients_vertical_id: clients_vertical.id, format: 'xls'
        expect(response).to be_success
      end

      it 'returns file' do
        expect(@controller).to receive(:send_data)
        get :by_client, clients_vertical_id: clients_vertical.id, format: 'xls'
        expect(response.header['Content-Type']).to eq('application/xls; charset=utf-8')
      end
    end

  end

end
