class CreateAffiliate < ActiveRecord::Migration
  def change
    create_table :affiliates do |t|
      t.string :token

      t.timestamps null: false
    end

    add_index :affiliates, :token, unique: true
  end
end
