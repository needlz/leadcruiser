class CreateDetailsPets < ActiveRecord::Migration
  def up
    create_table :details_pets do |t|
      t.string :species
      t.boolean :sprayed_or_neutered
      t.string :pet_name
      t.string :breed
      t.integer :birth_day, default: 1
      t.integer :birth_month
      t.integer :birth_year
      t.string :gender
      t.boolean :conditions
      t.string :list_of_conditions
      t.integer :lead_id
      t.timestamps
    end
  end

  def down
    drop_table :details_pets
  end
end
