# == Schema Information
#
# Table name: sites
#
#  id           :integer          not null, primary key
#  domain       :string(255)
#  host         :string(255)
#  site_ip      :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  affiliate_id :integer
#

class Site < ActiveRecord::Base
  has_many :leads
  belongs_to :affiliate
end
