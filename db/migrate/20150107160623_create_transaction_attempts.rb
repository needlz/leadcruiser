class CreateTransactionAttempts < ActiveRecord::Migration
  def change
    create_table :transaction_attempts do |t|
    	t.integer :lead_id
    	t.integer :client_id
    	t.integer :purchase_order_id
    	t.integer :price
    	t.boolean :success
        t.boolean :exclusive_selling
    	t.text :reason
    	t.integer :response_id

    	t.timestamps
    end
  end
end
