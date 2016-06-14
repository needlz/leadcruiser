# == Schema Information
#
# Table name: zip_codes
#
#  id           :integer          not null, primary key
#  zip          :integer
#  primary_city :string(255)
#  state        :string(255)
#  timezone     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class ZipCode < ActiveRecord::Base
  belongs_to :lead, foreign_key: 'zip', primary_key: 'zip'
end
