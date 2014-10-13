require 'rails_helper'
require 'api_helper'


  describe 'Api::V1::LeadsController', type: :request  do

    it 'creates lead with visitor' do
      expect(Visitor).to receive(:create)
                         .with({os: 'Linux', visitor_ip: '127.0.0.1', session_hash: '#234-22'})

      expect(Lead).to receive(:create)
                      .with({ session_hash: '#234-22'})

      api_post 'leads', { visitor: { os: 'Linux', visitor_ip: '127.0.0.1', session_hash: '#234-22' }, lead: { session_hash: '#234-22' } }

    end
  end


