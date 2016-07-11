module FactoryHelper
  FactoryGirl.define do
    factory :admin_user do
    end

    factory :pet, class: 'DetailsPet' do
      species 'dog'
      spayed_or_neutered 'false'
      pet_name 'Alapaha'
      breed 'Alapaha Blue Blood Bulldog'
      birth_month 12
      birth_year 1998
      gender 'male'
      conditions 'true'
    end

    factory :lead, class: 'Lead' do
      first_name 'John'
      last_name 'Doe'
      session_hash '#234-22'
      vertical_id 1
      site_id 1
      zip 10001
      day_phone '2-12-22'
      email 'test@example.com'

      trait :with_city_and_state do
        city 'Alabama'
        state 'AL'
      end

      trait :from_boberdoo do
        city 'Alabama'
        state 'AL'
        birth_date '06.07.1990'
      end

    end

    factory :health_insurance_lead, class: 'HealthInsuranceLead' do
      boberdoo_type 'type'
      src 'source'
      landing_page 'http://gethealthcare.co'
      age 25
    end

    factory :client_dog_breed_mapping, class: 'ClientDogBreedMapping' do
      integration_name 'pet_premium'
      name 'Bulldog'
    end

    factory :dog_breed, class: 'DogBreed' do
      name 'Alapaha Blue Blood Bulldog'
    end

    factory :zip_code, class: 'ZipCode' do
      zip 10001
      primary_city "New York"
      state "NY"
    end

    factory :clients_vertical, class: 'ClientsVertical' do
      integration_name 'pet_premium'
      active true
      exclusive true
      display true
      service_url 'url'
    end

    factory :vertical do
      next_client 'Yurii'
    end

    factory :clicks_purchase_order, class: 'ClicksPurchaseOrder' do
      active true
    end

    factory :tracking_page, class: 'TrackingPage' do
      link 'test_link'
    end

    factory :purchase_order, class: 'PurchaseOrder' do
      price 25
      active true
    end

    factory :response, class: 'Response' do
      response 'text'
      price 1
    end

    factory :transaction_attempt, class: 'TransactionAttempt' do
      success true
    end

    factory :block_list, class: 'BlockList' do
      active true
    end

    factory :visitor, class: 'Visitor' do
      session_hash "r6ut84b8pfjem64r3lib7fme33"
    end

    factory :hit, class: 'GethealthcareHit' do
    end

    factory :site, class: 'Site' do
    end
  end
end
