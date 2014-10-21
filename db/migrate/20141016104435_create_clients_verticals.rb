class CreateClientsVerticals < ActiveRecord::Migration
  def change
    create_table :clients_verticals do |t|
      t.integer :vertical_id
      t.string :integration_name
      t.boolean :active
      t.integer :weight
      t.boolean :exclusive
      t.float :fixed_price

      t.timestamps
    end
  end
end
