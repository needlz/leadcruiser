require 'rails_helper'
require 'api_helper'


describe 'API::V1::VisitorsController', type: :request do

  describe '#create' do
    let (:correct_data) { { os: 'Linux', visitor_ip: '127.0.0.1', session_hash: '#234-22' } }
    let (:wrong_data) { correct_data.except(:session_hash) }

    it 'returns success' do
      api_post 'visitors', visitor: correct_data
      result = JSON.parse response.body

      expect(result['message']).to eq('Visitor was created successfully')
    end

    it 'creates visitor with session_hash' do
      api_post 'visitors', visitor: correct_data

      expect(Visitor.where(session_hash: '#234-22').exists?).to eq(true)
    end

    it 'returns error without session_hash' do
      api_post 'visitors', visitor: wrong_data
      result = JSON.parse response.body

      expect(result['errors']).to eq(["Session hash cannot be blank"])
    end

    it 'does not create visitor without session_hash' do
      api_post 'visitors', visitor: wrong_data

      expect(Visitor.count).to eq(0)
    end

  end

end


