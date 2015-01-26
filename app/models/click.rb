class Click < ActiveRecord::Base
	validates :visitor_id, :site_id, presence: true

	has_one :visitor
	belongs_to :clients_vertical
end