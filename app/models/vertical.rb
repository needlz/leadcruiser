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
end
