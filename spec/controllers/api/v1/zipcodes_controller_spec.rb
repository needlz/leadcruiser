require 'rails_helper'
require 'api_helper'

describe API::V1::ZipcodesController, type: :request do
  let(:correct_zip) { 79021 }
  let(:wrong_zip) { 11111 }

  describe 'CREATE zipcode' do
    describe 'if valid zipcode' do
      before do
        stub_successfull_request
      end

      it 'returns info about zipcode place' do
        result = api_post 'zipcodes', zipcode: { zip: correct_zip }

        expect(result['errors']).not_to be_present
        expect(result['response']).to be_present
      end
    end

    describe 'if not valid zipcode' do
      before do
        stub_failed_request
      end

      it 'returns error message' do
        result = api_post 'zipcodes', zipcode: { zip: wrong_zip }

        expect(result['errors']).to eq "invalid zipcode"
      end

      it 'returns expected status' do
        api_post 'zipcodes', zipcode: { zip: wrong_zip }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  def stub_successfull_request
    stub_request(:get, "https://api.smartystreets.com/zipcode?auth-id=&auth-token=&zipcode=" + correct_zip.to_s).
        with(:headers => { 'Accept':'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby' }).
        to_return(:status => 200,
                  :body => [{ city_states: [{ city: 'Cotton Center' }] }].to_json,
                  :headers => {'Content-Type' =>  'application/json; charset=utf-8'}
        )
  end

  def stub_failed_request
    stub_request(:get, "https://api.smartystreets.com/zipcode?auth-id=&auth-token=&zipcode=" + wrong_zip.to_s).
        with(:headers => { 'Accept':'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby' }).
        to_return(:status => 200,
                  :body => [{ city_states: nil }].to_json,
                  :headers => {'Content-Type' =>  'application/json; charset=utf-8'}
        )
  end
end
