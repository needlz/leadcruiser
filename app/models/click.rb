# == Schema Information
#
# Table name: clicks
#
#  id                       :integer          not null, primary key
#  visitor_ip               :string(255)
#  clients_vertical_id      :integer
#  site_id                  :integer
#  page_id                  :integer
#  partner_id               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  clicks_purchase_order_id :integer
#  status                   :string(255)
#

class Click < ActiveRecord::Base
	include ErrorMessages

	validates :visitor_ip, :clients_vertical_id, presence: true

	belongs_to :clients_vertical
	belongs_to :clicks_purchase_order

	SOLD = "sold"
	DUPLICATED = "duplicated"

	def sold!
		update_attributes!(status: SOLD)
	end

	def sold?
		status == SOLD
	end

end
