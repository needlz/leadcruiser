# == Schema Information
#
# Table name: cat_breeds
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class CatBreed < ActiveRecord::Base
end
