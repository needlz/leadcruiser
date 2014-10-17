class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.string :response
      t.string :client_times_sold
      t.string :client_offer_amount
      t.boolean :client_offer_accept
      t.string :error_reasons
      t.string :rejection_reasons

      t.timestamps
    end
  end
end
