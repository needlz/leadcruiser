class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
    	t.integer :vertical_id
    	t.string :client_name
    	t.string :state_filter
    	t.string :pre_conditions
    	t.float :price
    	t.string :status
    	t.boolean :activated
    	t.integer :max_leads
    	t.integer :daily_leads

    	t.date :start_date
    	t.date :expiration_date

    	t.timestamps
    end
  end
end
