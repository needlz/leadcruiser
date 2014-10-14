require 'rails_helper'
require 'api_helper'


describe 'API::V1::LeadsController', type: :request do
  let (:session_hash) { '#234-22' }
  let (:correct_data) { { first_name: 'John', last_name: 'Doe', session_hash: session_hash } }
  let (:wrong_data) { correct_data.except(:session_hash) }

  describe '#create with visitor' do
    let! (:visitor) { Visitor.create(session_hash: session_hash) }
    it 'returns success' do
      api_post 'leads', lead: correct_data
      result = JSON.parse response.body

      expect(result['session_hash']).to eq(session_hash)
      expect(result['first_name']).to eq('John')
    end

    it 'creates lead with session_hash' do
      api_post 'leads', lead: correct_data

      expect(Lead.where(session_hash: session_hash).exists?).to eq(true)
    end
  end

  describe '#create without visitor' do
    it 'returns error without session_hash' do
      api_post 'leads', lead: wrong_data
      result = JSON.parse response.body

      expect(result['error']).to eq("There are no visitor connected with this lead by session_hash")
    end

    it 'does not create lead without session_hash' do
      api_post 'leads', lead: wrong_data

      expect(Visitor.count).to eq(0)
    end

  end

end
