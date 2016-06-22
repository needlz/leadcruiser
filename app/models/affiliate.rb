# == Schema Information
#
# Table name: affiliates
#
#  id         :integer          not null, primary key
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Affiliate < ActiveRecord::Base
  validates :token, presence: true
  validates_uniqueness_of :token

  has_many :sites
end
