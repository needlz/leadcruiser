class ClicksPurchaseOrder < ActiveRecord::Base
	belongs_to :clients_vertical, foreign_key: 'clients_vertical_id', primary_key: 'id'
end