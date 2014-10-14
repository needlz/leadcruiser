require 'rails_helper'
require 'api_helper'


  describe 'API::V1::LeadsController', type: :request  do
    describe '#create' do
      let (:correct_data) { { first_name: 'John', last_name: 'Doe', session_hash: '#234-22' } }
      let (:wrong_data) { correct_data.except(:session_hash) }

      it 'returns success' do
        api_post 'leads', lead: correct_data
        result = JSON.parse response.body

        expect(result['session_hash']).to eq('#234-22')
        expect(result['first_name']).to eq('John')
      end

      it 'creates lead with session_hash' do
        api_post 'leads', lead: correct_data

        expect(Lead.where(session_hash: '#234-22').exists?).to eq(true)
      end

      it 'returns error without session_hash' do
        api_post 'leads', lead: wrong_data
        result = JSON.parse response.body

        expect(result['session_hash'].to_s).to eq("[\"can't be blank\"]")
      end

      it 'does not create lead without session_hash' do
        api_post 'leads', lead: wrong_data

        expect(Visitor.count).to eq(0)
      end

    end

  end
