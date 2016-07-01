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

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
  Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

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
      Child_4_Preexisting_Conditions:'Yes'
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
    }.merge(hash)
  end
end
