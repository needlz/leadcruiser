class CreateClientCatBreedMappings < ActiveRecord::Migration
  def up
    create_table :client_cat_breed_mappings do |t|
      t.integer :breed_id
      t.string :integration_name
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :client_cat_breed_mappings
  end
end
