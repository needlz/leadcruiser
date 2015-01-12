class ChangeClientNameToPurchaseOrder < ActiveRecord::Migration
  def change
  	remove_column :purchase_orders, :client_name
  	add_column :purchase_orders, :client_id, :integer
  end
end
