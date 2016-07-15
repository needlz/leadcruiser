require 'rails_helper'

RSpec.describe HealthInsuranceMailer do

  before do
    Settings.sendgrid_api_key = ''
  end

  describe '#thank_you' do
    let(:site_domain) { HealthInsuranceMailer::SENDGRID_TEMPLATE_IDS[RequestToBoberdoo::HEALTH_INSURANCE_TYPE].keys[0] }
    let(:site) { create(:site, domain: site_domain) }
    let(:lead) { create(:lead, :from_boberdoo, site: site) }
    let!(:health_insurance_lead) { create(:health_insurance_lead, lead: lead, boberdoo_type: RequestToBoberdoo::HEALTH_INSURANCE_TYPE) }
    let(:name) { lead.name }
    let(:email) { lead.email }

    it 'creates valid email' do
      template_id = HealthInsuranceMailer::SENDGRID_TEMPLATE_IDS[RequestToBoberdoo::HEALTH_INSURANCE_TYPE][site_domain]
      stub_request(:post, "https://api.sendgrid.com/v3/mail/send").
        with(:body => "{\"from\":{\"email\":\"test@leadcruiser.com\"},\"personalizations\":[{\"to\":[{\"email\":\"#{ email }\",\"name\":\"#{ name }\"}],\"substitutions\":{\"\\u0026lt;%FirstName%\\u0026gt;\":\"#{ lead.first_name }\"}}],\"content\":[{\"type\":\"text/html\",\"value\":\"?\"}],\"template_id\":\"#{ template_id }\"}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>"Bearer #{ Settings.sendgrid_api_key }", 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => '', :headers => {})

      expect { HealthInsuranceMailer.new.thank_you(lead.id) }.to_not raise_error
    end
  end

  describe '#notify_about_gethealthcare_threshold' do
    let(:owner_emails) { 3.times.collect { Faker::Internet.email } }
    let(:owner_emails_string) { owner_emails.join(', ') }

    before do
      EditableConfiguration.create!(gethealthcare_notified_recipients_comma_separated: owner_emails_string)
    end

    it 'creates valid email' do
      emails_json = owner_emails.map { |email| { email: email } }.to_json
      stub_request(:post, "https://api.sendgrid.com/v3/mail/send").
        with(:body => "{\"from\":{\"email\":\"test@leadcruiser.com\"},\"personalizations\":[{\"to\":#{ emails_json }}],\"content\":[{\"type\":\"text/html\",\"value\":\"?\"}],\"template_id\":\"da47c791-c268-4ab6-a03d-6dbe98732a79\"}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>"Bearer #{ Settings.sendgrid_api_key }", 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {}).to_return(:status => 200, :body => "", :headers => {})

      expect { HealthInsuranceMailer.new.notify_about_gethealthcare_threshold }.to_not raise_error
    end
  end

  describe '#notify_about_gethealthcare_errors' do
    let(:owner_emails) { 3.times.collect { Faker::Internet.email } }
    let(:owner_emails_string) { owner_emails.join(', ') }

    before do
      EditableConfiguration.create!(gethealthcare_notified_recipients_comma_separated: owner_emails_string)
    end

    it 'creates valid email' do
      emails_json = owner_emails.map { |email| { email: email } }.to_json
      stub_request(:post, "https://api.sendgrid.com/v3/mail/send").
        with(:body => "{\"from\":{\"email\":\"test@leadcruiser.com\"},\"personalizations\":[{\"to\":#{ emails_json }}],\"content\":[{\"type\":\"text/html\",\"value\":\"?\"}],\"template_id\":\"a787181a-b883-48b5-9fda-dc335d8349b1\"}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>"Bearer #{ Settings.sendgrid_api_key }", 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {}).to_return(:status => 200, :body => "", :headers => {})

      expect { HealthInsuranceMailer.new.notify_about_gethealthcare_errors }.to_not raise_error
    end
  end

end
