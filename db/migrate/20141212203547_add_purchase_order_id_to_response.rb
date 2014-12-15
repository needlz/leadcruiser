class AddPurchaseOrderIdToResponse < ActiveRecord::Migration
  def change
  	add_column :responses, :purchase_order_id, :integer
  end
end
