class ChangePriceWeightToPurchaseOrder < ActiveRecord::Migration
  def change
  	change_column :purchase_orders, :weight, :float
  	change_column :transaction_attempts, :price, :float
  end
end
