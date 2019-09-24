# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:transaction)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, concurrent: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

  RSpec::Sidekiq.configure do |config|
    config.warn_when_jobs_not_processed_by_sidekiq = false
  end

  class Fork
    def return_value
      # causes <Errno::EPIPE: Broken pipe> exception in ForkBreak process
    end
  end

  class Object
    def concurrent_calls(stubbed_methods, called_method, options={}, &block)
      ActiveRecord::Base.connection.disconnect!
      options.reverse_merge!(count: 2)
      processes = options[:count].times.map do |i|
        ForkBreak::Process.new do |breakpoints|
          ActiveRecord::Base.establish_connection

          # Add a breakpoint after invoking the method
          stubbed_methods.each do |stubbed_method|
            original_method = self.method(stubbed_method)
            self.stub(stubbed_method) do |*args|
              res = original_method.call(*args)
              breakpoints << stubbed_method
              res
            end
          end

          self.send(called_method)
        end
      end
      block.call(processes)
    ensure
      ActiveRecord::Base.establish_connection
    end
  end

  # 'rspec-activejob' gem lacks of precision matchers
  module RSpec
    module ActiveJob
      module Matchers
        class EnqueueA
          def at_correct_time_with_within?
            if @time
              !new_jobs_with_correct_class.find { |job| (job[:at].to_f - @time.to_f).abs < @within_radius.to_f }.nil?
            else
              at_correct_time_without_within?
            end
          end

          def enqueued_at_wrong_time_message_with_within
            return if at_correct_time?
            if @time
              "expected to run job at #{Time.at(@time).utc}, but enqueued to " \
              "run at #{format_enqueued_times}"
            else
              enqueued_at_wrong_time_message_without_within
            end
          end

          alias_method_chain :at_correct_time?, :within
          alias_method_chain :enqueued_at_wrong_time_message, :within

          def of(time)
            @time = time
            self
          end

          def be_within(radius_secs)
            @within_radius = radius_secs
            self
          end
        end
      end
    end
  end

  def params_for_health_lead(hash = {})
    {
      session_hash: 'session hash',
      site_id: '1',
      form_id: '1',
      TYPE: RequestToBoberdoo::HEALTH_INSURANCE_TYPE,
      Test_Lead: '1',
      Skip_XSL: '1',
      Match_With_Partner_ID: '22.456',
      Redirect_URL: 'http://www.yoursite.com/',
      SRC: 'test',
      Landing_Page: 'landing',
      IP_Address: '75.2.92.149',
      Sub_ID: '12',
      Pub_ID: '12345',
      Optout: 'Optout',
      imbx: 'imbx',
      Ref: 'Ref',
      user_agent: 'user_agent',
      tsrc: 'tsrc',
      First_Name: 'John',
      Last_Name: 'Doe',
      Address_1: 'Address_1',
      Address_2: 'Address_2',
      City: 'Chicago',
      State: 'IL',
      Zip: '60610',
      Phone_Number: '3125554811',
      Email_Address: 'test@nags.us',
      FPL: '<138%M',
      DOB: '12/23/1980',
      Gender: 'Male',
      Age: '5',
      Height_Feet: '12',
      Height_Inches: '12',
      Weight: '8',
      Tobacco_Use: 'Yes',
      Preexisting_Conditions: 'Yes',
      Household_Income: '6',
      Household_Size: '6',
      Qualifying_Life_Event: 'Lost/Losing Coverage',
      Spouse_Gender: 'Male',
      Spouse_Age: '8',
      Spouse_Height_Feet: '12',
      Spouse_Height_Inches: '8',
      Spouse_Weight: '11',
      Spouse_Tobacco_Use: 'Yes',
      Spouse_Preexisting_Conditions: 'Yes',
      Child_1_Gender: 'Male',
      Child_1_Age: '6',
      Child_1_Height_Feet: '10',
      Child_1_Height_Inches: '6',
      Child_1_Weight: '8',
      Child_1_Tobacco_Use: 'Yes',
      Child_1_Preexisting_Conditions:'Yes',
      Child_2_Gender: 'Male',
      Child_2_Age: '8',
      Child_2_Height_Feet: '11',
      Child_2_Height_Inches: '7',
      Child_2_Weight: '4',
      Child_2_Tobacco_Use: 'Yes',
      Child_2_Preexisting_Conditions:'Yes',
      Child_3_Gender: 'Male',
      Child_3_Age: '9',
      Child_3_Height_Feet: '9',
      Child_3_Height_Inches: '9',
      Child_3_Weight: '9',
      Child_3_Tobacco_Use: 'Yes',
      Child_3_Preexisting_Conditions:'Yes',
      Child_4_Gender: 'Male',
      Child_4_Age: '12',
      Child_4_Height_Feet: '15',
      Child_4_Height_Inches: '15',
      Child_4_Weight: '7',
      Child_4_Tobacco_Use: 'Yes',
      Child_4_Preexisting_Conditions:'Yes',
      eHealth_url: 'http://www.ehealthinsurance.com/111',
      leadid_token: '52EC333B-0A42-562D-EF4A-23FDFC76B2FF',
      visitor_id: '2cp3tbc41v6b8g8ccdi86nbq85',
      TrustedForm_cert_url: 'https://cert.trustedform.com/2de60f33e96df80fd7ad676c6b3ea6baf49eda31',
      TCPA_Consent: 'Consent',
      TCPA_Language: 'Language'
    }.merge(hash)
  end

  def params_for_medsupp_lead(hash = {})
    {
      session_hash: 'session hash',
      site_id: '1',
      form_id: '1',
      TYPE: RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE,
      Test_Lead: '1',
      Skip_XSL: '1',
      Match_With_Partner_ID: '22.456',
      Redirect_URL: 'http://www.yoursite.com/',
      SRC: 'test',
      Landing_Page: 'landing',
      IP_Address: '75.2.92.149',
      Sub_ID: '12',
      Pub_ID: '12345',
      Optout: 'Optout',
      imbx: 'imbx',
      Ref: 'Ref',
      user_agent: 'user_agent',
      tsrc: 'tsrc',
      First_Name: 'John',
      Last_Name: 'Doe',
      Address_1: 'Address_1',
      Address_2: 'Address_2',
      City: 'Chicago',
      State: 'IL',
      Zip: '60610',
      Phone_Number: '3125554811',
      Email_Address: 'test@nags.us',
      Bday: '12/23/1980',
      Gender: 'Male',
      Age: '5',
      eHealth_url: "http://www.ehealthinsurance.com/111",
      leadid_token: '52EC333B-0A42-562D-EF4A-23FDFC76B2FF',
      visitor_id: '2cp3tbc41v6b8g8ccdi86nbq85',
      TrustedForm_cert_url: 'https://cert.trustedform.com/2de60f33e96df80fd7ad676c6b3ea6baf49eda31',
      TCPA_Consent: 'Consent',
      TCPA_Language: 'Language'
    }.merge(hash)
  end
end
