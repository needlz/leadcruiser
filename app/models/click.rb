class Click < ActiveRecord::Base
	validates :visitor_id, :site_id, presence: true

	belongs_to :visitor
	belongs_to :clients_vertical
end