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
    end

    factory :vertical do
      id 1
      next_client 'Yurii'
    end

    factory :clicks_purchase_order, class: 'ClicksPurchaseOrder' do
      id 1
      active true
    end

    factory :tracking_page, class: 'TrackingPage' do
      id 1
      link 'test_link'
    end

    factory :purchase_order, class: 'PurchaseOrder' do
      states 'Texas, Colorado, Washington'
      price 25
    end

    factory :response, class: 'Response' do
      response 'text'
      price 1
    end

    factory :transaction_attempt, class: 'TransactionAttempt' do
      success true
    end
  end
end
