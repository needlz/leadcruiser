require 'rails_helper'
require 'api_helper'

describe API::V1::VisitorsController, type: :request do
  describe 'CREATE visitor with correct params' do
    it 'should create a visitor' do
      expect{ api_post 'visitors', visitor: correct_visitor_params  }.to change{ Visitor.count }.from(0).to(1)
    end

    it 'should respond with correct message' do
      result = api_post 'visitors', visitor: correct_visitor_params

      expect(result['message']).to eq 'Visitor was created successfully'
      expect(response).to have_http_status(:created)
      expect(result['visitor_id']).to eq Visitor.last.id
    end
  end

  describe 'CREATE visitor with no session hash' do
    it 'should not create visitor' do
      expect{ api_post 'visitors', visitor: correct_visitor_params.except(:session_hash) }.not_to change{ Visitor.count }
    end

    it 'should respond with error message' do
      result = api_post 'visitors', visitor: correct_visitor_params.except(:session_hash)

      expect(result['errors'].first).to eq "Session hash cannot be blank"
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

  private

  def correct_visitor_params
     {
        site_id: 1,
        session_hash: 'session_hash',
        visitor_ip: '127.0.0.15',
        referring_url: 'http://lctest/dogs/',
        referring_domain: 'http://lctest/',
        landing_page: '/dogs/',
        keywords: nil,
        utm_medium: nil,
        utm_source: nil,
        utm_campaign: nil,
        utm_term: nil,
        utm_content: nil,
        location: 'US',
        browser: 'Firefox',
        os: 'Mac OS X'
     }
  end
end