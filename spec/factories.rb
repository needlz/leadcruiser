module FactoryHelper
  FactoryGirl.define do
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
      city 'NY'
      zip 10001
      day_phone '2-12-22'
      email 'test@example.com'
    end

    factory :clients_vertical, class: 'ClientsVertical' do
      vertical_id 1
      integration_name 'pet_premium'
      active true
      exclusive true
    end

    factory :client_dog_breed_mapping, class: 'ClientDogBreedMapping' do
      integration_name 'pet_premium'
      name 'Bulldog'
    end

    factory :dog_breed, class: 'DogBreed' do
      name 'Alapaha Blue Blood Bulldog'
    end

    factory :vertical do

    end

  end
end