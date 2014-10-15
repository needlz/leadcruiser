require 'rails_helper'
require 'api_helper'


describe 'API::V1::LeadsController', type: :request do
  let (:session_hash) { '#234-22' }
  let (:correct_data) { { first_name: 'John', last_name: 'Doe', session_hash: session_hash, vertical_id: 1, site_id: 1, city: 'NY', zip: 10004, day_phone: '2-12-22', email: 'test@example.com' } }
  let (:pet_data) { { species: 'cat', sprayed_or_neutered: 'false', pet_name: 'kitty', breed: 'sphinx', birth_month: 12, birth_year: 1998, gender: 'male', conditions: false } }
  let (:wrong_data) { correct_data.except(:vertical_id) }

  describe '#create with visitor' do
    let! (:visitor) { Visitor.create(session_hash: session_hash) }

    it 'returns success' do
      api_post 'leads', lead: correct_data, pet: pet_data
      result = JSON.parse response.body

      expect(result['message']).to eq('Lead was created successfully')
    end

    it 'creates lead with session_hash' do
      api_post 'leads', lead: correct_data, pet: pet_data
      expect(Lead.where(session_hash: session_hash).exists?).to eq(true)
    end

    it 'creates pet' do
      api_post 'leads', lead: correct_data, pet: pet_data
      expect(DetailsPet.where(breed: 'sphinx').exists?).to eq(true)
    end
  end

  describe '#create without mandatory field' do
    it 'returns error without vertical_id' do
      api_post 'leads', lead: wrong_data, pet: pet_data
      result = JSON.parse response.body

      expect(result['errors']).to eq(["Vertical ID cannot be blank"])
    end

    it 'returns all errors for mandatory fields' do
      api_post 'leads'
      result = JSON.parse response.body

      expect(result['errors']).to eq(["Site cannot be blank", "Vertical ID cannot be blank", "Firstname cannot be blank",
                                      "Lastname cannot be blank", "ZIP cannot be blank", "Day phone cannot be blank",
                                      "Email cannot be blank", "is invalid", "Species cannot be blank", "Pet name cannot be blank",
                                      "Breed cannot be blank", "Birth month cannot be blank", "Birth year cannot be blank",
                                      "Gender cannot be blank", "Sprayed/neutered cannot be blank", "Conditions cannot be blank"])
    end

    it 'does not create lead without vertical_id' do
      api_post 'leads', lead: wrong_data, pet: pet_data

      expect(Visitor.count).to eq(0)
    end

  end

end
