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
end
