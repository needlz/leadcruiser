# == Schema Information
#
# Table name: dog_breeds
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class DogBreed < ActiveRecord::Base
end
