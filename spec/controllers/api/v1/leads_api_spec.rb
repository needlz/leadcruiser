require 'rails_helper'
require 'api_helper'

describe API::V1::LeadsController, type: :request do

  let (:message) do
    "Thanks for submitting your information!<br />Check your email for quotes and exciting offers for [pets_name]."
  end
  let(:session_hash) { '#234-22' }
  let!(:vertical) { create(:vertical, name: Vertical::PET_INSURANCE) }
  let!(:clients_vertical) { create(:clients_vertical, vertical_id: vertical.id) }
  let(:site) { create(:site) }
  let(:correct_data) { { first_name: 'John',
                         last_name: 'Doe',
                         session_hash: session_hash,
                         vertical_id: vertical.id,
                         site_id: site.id,
                         city: 'New York',
                         state: 'NY',
                         zip: 10004,
                         day_phone: '2-12-22',
                         email: 'test@example.com' } }
  let(:pet_data) { { species: 'cat',
                     spayed_or_neutered: 'false',
                     pet_name: 'kitty',
                     breed: 'sphinx',
                     birth_month: 12,
                     birth_year: 1998,
                     gender: 'male',
                     conditions: false } }
  let(:wrong_data) { correct_data.except(:first_name) }
  let(:wrong_pet_data) { { species: '',
                           spayed_or_neutered: '',
                           pet_name: '',
                           breed: '',
                           birth_month: 12,
                           birth_year: 1998,
                           gender: '',
                           conditions: false } }
  let(:data_with_sold_state) { correct_data.merge({ status: 'sold' }) }

  before do
    stub_request(:get, "https://api.smartystreets.com/zipcode?auth-id=&auth-token=&zipcode=10004").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => [{city_states: [{state_abbreviation: 'NY', city: 'New York'}]}].to_json, :headers => {})
  end

  describe '#create with visitor' do
    let! (:visitor) { Visitor.create(session_hash: session_hash) }

    it 'returns success' do
      result = api_post 'leads', lead: correct_data, pet: pet_data

      expect(result['errors']).to eq message.gsub('[pets_name]', pet_data[:pet_name])
    end

    it 'creates lead with session_hash' do
      expect{ api_post 'leads', lead: correct_data, pet: pet_data }.to change{Lead.count}.from(0).to(1)

      expect(Lead.last.session_hash).to eq session_hash
    end

    it 'creates lead with city and state' do
      api_post 'leads', lead: correct_data, pet: pet_data

      expect(Lead.where(city: 'New York', state: 'NY').exists?).to eq(true)
    end

    it 'creates pet' do
      api_post 'leads', lead: correct_data, pet: pet_data

      expect(DetailsPet.where(breed: 'sphinx').exists?).to eq(true)
    end
  end

  describe '#create without mandatory field' do
    it 'returns error without vertical_id' do
      result = api_post 'leads', lead: wrong_data, pet: pet_data

      expect(result['errors']).to eq message.gsub('[pets_name]', pet_data[:pet_name])
    end

    it 'returns all errors for mandatory fields' do
      api_post 'leads', lead: wrong_data, pet: wrong_pet_data
      result = JSON.parse response.body

      expect(result['errors']).to eq message.gsub('[pets_name]', wrong_pet_data[:pet_name])
    end

    it 'does not create lead without vertical_id' do
      api_post 'leads', lead: wrong_data, pet: pet_data

      expect(Visitor.count).to eq(0)
    end

  end

  describe 'validation on lead uniqueness' do
    let (:another_pet_data) { { species: 'cat',
                                spayed_or_neutered: 'false',
                                pet_name: 'Mediolan',
                                breed: 'Cymric',
                                birth_month: 12,
                                birth_year: 1998,
                                gender: 'male',
                                conditions: false } }
    let (:sensitive_case_pet_data) { { species: 'cat',
                                       spayed_or_neutered: 'false',
                                       pet_name: 'MediOlan',
                                       breed: 'Cymric',
                                       birth_month: 12,
                                       birth_year: 1998,
                                       gender: 'male',
                                       conditions: false } }
    let (:response) { create(:response) }

    it 'sets duplicated status if the same lead was sold' do
      api_post 'leads', lead: data_with_sold_state, pet: pet_data

      Lead.last.sold!
      response.update_attributes(lead_id: Lead.last.id)

      api_post 'leads', lead: data_with_sold_state, pet: pet_data

      expect(Lead.last.status).to eq(Lead::DUPLICATED)
    end
  end

  describe '#authorize' do

    context 'if site has no affiliate related to' do
      let(:site) { create(:site) }
      let(:correct_data) { { first_name: 'John',
                             last_name: 'Doe',
                             session_hash: session_hash,
                             vertical_id: vertical.id,
                             site_id: site.id,
                             city: 'New York',
                             state:'NY',
                             zip: 10004,
                             day_phone: '2-12-22',
                             email: 'test@example.com' } }

      it 'creates lead' do
        expect{ api_post 'leads', lead: correct_data, pet: pet_data }.to change{ Lead.count }.from(0).to(1)
      end
    end

    context 'if site has affiliate' do
      let(:affiliate) { create(:affiliate) }
      let(:site) { create(:site, affiliate: affiliate) }
      let(:correct_data) { { first_name: 'John',
                             last_name: 'Doe',
                             session_hash: session_hash,
                             vertical_id: vertical.id,
                             site_id: site.id,
                             city: 'New York',
                             state:'NY',
                             zip: 10004,
                             day_phone: '2-12-22',
                             email: 'test@example.com' } }

      context 'when token given in params' do
        context 'and it equals to stored token' do
          it 'creates lead' do
            expect{ api_post 'leads', lead: correct_data, pet: pet_data, token: affiliate.token }
                .to change{ Lead.count }.from(0).to(1)
          end
        end

        context 'and saved token is different' do
          it "returns 'authorization required'" do
            api_post 'leads', lead: correct_data, pet: pet_data, token: 'token'

            expect(response).to have_http_status(:unauthorized)
          end
        end
      end

      context 'when there is no token in params' do
        it "returns 'authorization required'" do
          api_post 'leads', lead: correct_data, pet: pet_data

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
