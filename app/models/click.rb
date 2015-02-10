class Click < ActiveRecord::Base
	validates :visitor_ip, :clients_vertical_id, presence: true

	belongs_to :clients_vertical
	belongs_to :clicks_purchase_order

	SOLD = "sold"
	DUPLICATED = "duplicated"
end