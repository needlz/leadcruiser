require 'rails_helper'

RSpec.describe ReportsController, :type => :controller do
  render_views

  describe '#index' do
    it 'returns success' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    context 'when requesting html format' do
      it 'renders template' do
        get :index, format: 'html'
        expect(response).to render_template(:index)
      end

      it 'renders leads and leads per day' do
        get :index, format: 'html'
        expect(assigns(:leads)).not_to be_nil
        expect(assigns(:leads_per_day)).not_to be_nil
      end
    end

    context 'when requesting js format' do
      it 'renders template' do
        xhr :get, :index, format: 'js'
        expect(response).to render_template(:index)
      end

      it 'renders leads and leads per day' do
        xhr :get, :index, format: 'js'
        expect(assigns(:leads)).not_to be_nil
        expect(assigns(:leads_per_day)).not_to be_nil
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

  describe '#refresh' do
    it 'returns success' do
      get :refresh
      expect(response).to have_http_status(:ok)
    end

    it "renders statistic in 'days' json field" do
      get :refresh
      expect(JSON.parse(response.body)['days']).to be_present
    end

    it 'renders statistic for given date range' do
      get :refresh, firstDate: '2016-05-10', secondDate: '2016-06-10'
      expect(JSON.parse(response.body)['days']).to be_present
    end
  end

end
