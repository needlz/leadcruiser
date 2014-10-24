require 'rails_helper'

RSpec.describe DetailsPet, :type => :model do
  let (:lead) { create(:lead) }
  let (:pet) { create(:pet, lead_id: lead.id) }

  describe '#breed_to_send' do
    let! (:client_dog_breed_mapping) { create(:client_dog_breed_mapping, breed_id: dog_breed.id) }
    let (:dog_breed) { create(:dog_breed) }

    it 'returns breed from mapping table' do
      create(:clients_vertical)
      expect(pet.breed_to_send(client_dog_breed_mapping.integration_name)).to eq(client_dog_breed_mapping.name)
    end
    it 'returns pet breed if there are no mapping' do
      expect(pet.breed_to_send).to eq(dog_breed.name)
    end
  end

  describe '#conditions?' do
    it 'returns Yes for pet with conditions' do
      expect(pet.conditions?).to eq('Yes')
    end

    it 'returns No for pet without conditions' do
      pet.conditions = 'false'
      expect(pet.conditions?).to eq('No')
    end
  end

  describe '#spayed?' do
    it 'returns Yes for pet with spayed_or_neutered' do
      pet.spayed_or_neutered = 'true'
      expect(pet.spayed?).to eq('Yes')
    end

    it 'returns No for pet without spayed_or_neutered' do
      expect(pet.spayed?).to eq('No')
    end
  end
end
