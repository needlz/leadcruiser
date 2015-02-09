class ClicksPurchaseOrder < ActiveRecord::Base
	belongs_to :clients_vertical, foreign_key: 'clients_vertical_id', primary_key: 'id'
	belongs_to :tracking_page, foreign_key: 'page_id', primary_key: 'id'
end