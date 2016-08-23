require 'rails_helper'

RSpec.describe AddSendgridContact do

  let!(:vertical) { create(:vertical, name: Vertical::HEALTH_INSURANCE) }
  let!(:lead) { create(:lead,
                       birth_date: Time.current,
                       first_name: Faker::Name.first_name,
                       last_name: Faker::Name.last_name,
                       gender: 'Female',
                       zip: '1234',
                       email: Faker::Internet.email) }
  let!(:health_insurance_lead) { create(:health_insurance_lead,
                                        lead: lead,
                                        fpl: 'fpl',
                                        qualifying_life_event: 'life event',
                                        boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE)
  }
let(:add) { AddSendgridContact.new(lead) }

  let!(:request) { stub_request(:post, "https://api.sendgrid.com/v3/contactdb/recipients").
      with(:body => "[{\"Birth_Date\":\"#{ lead.birth_date.strftime("%m/%d/%Y") }\",\"email\":\"#{ lead.email }\",\"first_name\":\"#{ lead.first_name }\",\"last_name\":\"#{ lead.last_name }\",\"Zip\":\"#{ lead.zip }\",\"Gender\":\"#{ lead.gender }\",\"Lead_Type\":\"#{ lead.health_insurance_lead.lead_type }\",\"FPL\":\"#{ lead.health_insurance_lead.fpl }\",\"Life_Event\":\"#{ lead.health_insurance_lead.qualifying_life_event }\"}]",
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer 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', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "{\"error_count\":0}", :headers => {})
  }

  describe '#perform' do
    it 'sends contact to SendGrid' do
      add.perform
      expect(request).to have_been_requested
    end

    context 'on SendGrid error' do
      before do
        stub_request(:post, "https://api.sendgrid.com/v3/contactdb/recipients").
          with(:body => "[{\"Birth_Date\":\"#{ lead.birth_date.strftime("%m/%d/%Y") }\",\"email\":\"#{ lead.email }\",\"first_name\":\"#{ lead.first_name }\",\"last_name\":\"#{ lead.last_name }\",\"Zip\":\"#{ lead.zip }\",\"Gender\":\"#{ lead.gender }\",\"Lead_Type\":\"#{ lead.health_insurance_lead.lead_type }\",\"FPL\":\"#{ lead.health_insurance_lead.fpl }\",\"Life_Event\":\"#{ lead.health_insurance_lead.qualifying_life_event }\"}]",
               :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer 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', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
          to_return(:status => 201,
                    :body => "{\"error_count\":1,\"error_indices\":[0],\"errors\":[{\"error_indices\":[0],\"message\":\"The following parameters are not custom fields or reserved fields: [last_namec]\"}],\"new_count\":0,\"persisted_recipients\":[],\"unmodified_indices\":[],\"updated_count\":0}",
                    :headers => {})
      end

      it 'raises error' do
        expect { add.perform }.to raise_error(AddSendgridContact::Error)
      end
    end
  end

end


