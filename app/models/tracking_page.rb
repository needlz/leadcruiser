# == Schema Information
#
# Table name: tracking_pages
#
#  id                  :integer          not null, primary key
#  link                :string(255)
#  display_order       :integer
#  created_at          :datetime
#  updated_at          :datetime
#  clients_vertical_id :integer
#

class TrackingPage < ActiveRecord::Base
	belongs_to :clients_vertical
end
