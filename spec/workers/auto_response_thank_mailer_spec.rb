require 'rails_helper'

RSpec.describe AutoResponseThankMailer do

  let(:email) { Faker::Internet.email }

  describe '#send_email' do
    it 'does not send mail if Mandrill key is not set' do
      expect(Settings.mandrill_api_key).to be_blank
      expect_any_instance_of(AutoResponseThankMailer).to_not receive(:api)
      AutoResponseThankMailer.new.send_email(email)
    end
  end

end
