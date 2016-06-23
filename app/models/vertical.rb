# == Schema Information
#
# Table name: verticals
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  next_client :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  times_sold  :integer
#

class Vertical < ActiveRecord::Base
  has_many :leads
  has_many :clients_verticals
  has_many :purchase_orders

  PET_INSURANCE = 'pet_insurance'
  HEALTH_INSURANCE = 'health_insurance'

  def self.pet_insurance
    find_by_name(PET_INSURANCE)
  end

  def self.health_insurance
    find_by_name(HEALTH_INSURANCE)
  end

end
