require 'rails_helper'

RSpec.describe HealthInsuranceMailer do

  before do
    Settings.sendgrid_api_key = ''
  end

  describe '#thank_you' do
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email }

    it 'creates valid email' do

      stub_request(:post, "https://api.sendgrid.com/v3/mail/send").
        with(:body => "{\"from\":{\"email\":\"test@leadcruiser.com\"},\"personalizations\":[{\"to\":[{\"email\":\"#{ email }\",\"name\":\"#{ name }\"}],\"substitutions\":{\"-site_name-\":\"site_name\"}}],\"content\":[{\"type\":\"text/plain\",\"value\":\"?\"}],\"template_id\":\"56a6f854-8c13-425e-8835-e88ec9d476a7\"}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>"Bearer #{ Settings.sendgrid_api_key }", 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})

      expect { HealthInsuranceMailer.new.thank_you(name: name,
                                                   email: email,
                                                   site_name: 'site_name') }.to_not raise_error
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
        with(:body => "{\"from\":{\"email\":\"test@leadcruiser.com\"},\"personalizations\":[{\"to\":#{ emails_json }}],\"content\":[{\"type\":\"text/plain\",\"value\":\"?\"}],\"template_id\":\"da47c791-c268-4ab6-a03d-6dbe98732a79\"}",
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
        with(:body => "{\"from\":{\"email\":\"test@leadcruiser.com\"},\"personalizations\":[{\"to\":#{ emails_json }}],\"content\":[{\"type\":\"text/plain\",\"value\":\"?\"}],\"template_id\":\"a787181a-b883-48b5-9fda-dc335d8349b1\"}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>"Bearer #{ Settings.sendgrid_api_key }", 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {}).to_return(:status => 200, :body => "", :headers => {})

      expect { HealthInsuranceMailer.new.notify_about_gethealthcare_errors }.to_not raise_error
    end
  end

end
