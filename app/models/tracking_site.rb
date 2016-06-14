# == Schema Information
#
# Table name: tracking_sites
#
#  id            :integer          not null, primary key
#  site_name     :string(255)
#  display_order :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class TrackingSite < ActiveRecord::Base
end
