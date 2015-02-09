class AddPurchaseOrderIdToClicks < ActiveRecord::Migration
  def change
  	rename_column :clicks, :visitor_id, :visitor_ip
  	change_column :clicks, :visitor_ip, :string
  	add_column :clicks, :clicks_purchase_order_id, :integer
  end
end
