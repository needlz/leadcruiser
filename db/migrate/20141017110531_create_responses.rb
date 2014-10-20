class CreateResponses < ActiveRecord::Migration
  def up
    create_table :responses do |t|
      t.text :response
      t.string :client_times_sold
      t.string :client_offer_amount
      t.boolean :client_offer_accept
      t.text :error_reasons
      t.text :rejection_reasons

      t.timestamps
    end
  end

  def down
    drop_table :responses
  end
end
