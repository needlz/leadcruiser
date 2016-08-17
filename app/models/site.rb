# == Schema Information
#
# Table name: sites
#
#  id         :integer          not null, primary key
#  domain     :string(255)
#  host       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Site < ActiveRecord::Base
  has_many :leads

  def display_name
    host
  end

end
