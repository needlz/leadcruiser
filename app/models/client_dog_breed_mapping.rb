# == Schema Information
#
# Table name: client_dog_breed_mappings
#
#  id               :integer          not null, primary key
#  breed_id         :integer
#  integration_name :string(255)
#  name             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  client_breed_id  :integer
#

class ClientDogBreedMapping < ActiveRecord::Base
end
