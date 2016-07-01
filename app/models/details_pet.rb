# == Schema Information
#
# Table name: details_pets
#
#  id                 :integer          not null, primary key
#  species            :string(255)
#  spayed_or_neutered :boolean
#  pet_name           :string(255)
#  breed              :string(255)
#  birth_day          :integer          default(1)
#  birth_month        :integer
#  birth_year         :integer
#  gender             :string(255)
#  conditions         :boolean
#  lead_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class DetailsPet < ActiveRecord::Base
  include ErrorMessages
  validates :species, :pet_name, :breed, :birth_month, :birth_year, :gender,  presence: true
  validates_inclusion_of :spayed_or_neutered, :conditions, in: [true, false]
  belongs_to :lead

  def spayed?
    return 'Yes' if spayed_or_neutered
    'No'
  end


  def conditions?
    return 'Yes' if conditions
    'No'
  end

  def breed_to_send(integration_name = nil)
    pet_type = species.capitalize
    breed_id = "#{pet_type}Breed".constantize.find_by_name(breed).try(:id)
    mapping_breed = "Client#{pet_type}BreedMapping".constantize.where(integration_name: integration_name,
                                                                      breed_id: breed_id)
                                                                      .try(:first)
                                                                      .try(:name)
    mapping_breed || breed
  end

  def breed_id_to_send(integration_name = nil)
    pet_type = species.capitalize
    breed_id = "#{pet_type}Breed".constantize.find_by_name(breed).try(:id)
    mapping_breed = "Client#{pet_type}BreedMapping".constantize.where(integration_name: integration_name,
                                                                      breed_id: breed_id)
                                                                      .try(:first)
                                                                      .try(:client_breed_id)
    mapping_breed || breed_id
  end

  def validate_same(other)
    result = breed == other.breed && pet_name.downcase == other.pet_name.downcase
    errors[:base] << I18n.t('pet_details_uniqueness_for_lead', breed: breed, pet_name: pet_name) if result
    result
  end

end
