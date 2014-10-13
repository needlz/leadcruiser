require 'rails_helper'

RSpec.describe LeadsController, :type => :controller do

  describe "#create" do
    it 'creates a visitor' do
      expect(Visitor).to receive(:create).
                             with({os: 'Linux', visitor_ip: '127.0.0.1', session_hash: '#234-22'})

      expect(Lead).to receive(:create).
                             with({ session_hash: '#234-22'}.with_indifferent_access)

      post :create, { visitor: { os: 'Linux', visitor_ip: '127.0.0.1', session_hash: '#234-22' }, lead: { session_hash: '#234-22' } }

    end
  end

end
