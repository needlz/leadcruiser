require 'rails_helper'

RSpec.describe DetailsPet, :type => :model do
  let (:lead) { create(:lead) }
  let (:pet) { create(:pet, lead_id: lead.id) }

  describe '#breed_to_send' do
    let (:dog_breed) { create(:dog_breed) }
    let! (:client_dog_breed_mapping) { create(:client_dog_breed_mapping, breed_id: dog_breed.id) }

    it 'returns breed from mapping table' do
       expect(pet.breed_to_send(client_dog_breed_mapping.integration_name)).to eq(client_dog_breed_mapping.name)
    end

    it 'returns pet breed if there are no mapping' do
      expect(pet.breed_to_send).to eq dog_breed.name
    end
  end

  describe '#breed_id_to_send' do
    let (:dog_breed) { create(:dog_breed) }
    let! (:client_dog_breed_mapping) { create(:client_dog_breed_mapping, breed_id: dog_breed.id, client_breed_id: 2 ) }

    it 'returns breed from mapping table' do
      expect(pet.breed_id_to_send(client_dog_breed_mapping.integration_name)).to eq(client_dog_breed_mapping.client_breed_id)
    end

    it 'returns pet breed if there are no mapping' do
      expect(pet.breed_id_to_send).to eq(dog_breed.id)
    end
  end

  describe '#conditions?' do
    let(:pet_without_conditions) { pet.update_attributes(conditions: 'false') }

    it 'returns Yes for pet with conditions' do
      expect(pet.conditions?).to eq('Yes')
    end

    it 'returns No for pet without conditions' do
      pet_without_conditions

      expect(pet.conditions?).to eq('No')
    end
  end

  describe '#spayed?' do
    let(:spayed_pet) { pet.update_attributes(spayed_or_neutered: 'true') }

    it 'returns Yes for pet with spayed_or_neutered' do
      spayed_pet

      expect(pet.spayed?).to eq('Yes')
    end

    it 'returns No for pet without spayed_or_neutered' do
      expect(pet.spayed?).to eq('No')
    end
  end

  describe '#validate_same' do
    let (:new_pet) { create(:pet, lead_id: lead.id) }
    let (:dog_breed) { create(:dog_breed) }
    let! (:client_dog_breed_mapping) { create(:client_dog_breed_mapping, breed_id: dog_breed.id) }

    describe 'if 2 pets are with same breed and name' do
      it 'returns true' do
        expect(pet.validate_same(new_pet)).to be_truthy
      end

      it 'adds message to errors' do
        ERROR_MESSAGE = "Lead with '#{pet.breed}' breed or '#{pet.pet_name}' name already exists"

        pet.validate_same(new_pet)

        expect(pet.errors[:base].first).to eq ERROR_MESSAGE
      end
    end

    describe 'if 2 pets are not with same name' do
      before do
        new_pet.update_attributes(pet_name: 'New Name')
      end

      it 'returns false' do
        expect(pet.validate_same(new_pet)).to be_falsey
      end

      it 'has no error messages' do
        pet.validate_same(new_pet)

        expect(pet.errors[:base].first).to be_nil
      end
    end

  end
end
