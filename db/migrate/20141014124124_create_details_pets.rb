class CreateDetailsPets < ActiveRecord::Migration
  def change
    create_table :details_pets do |t|
      t.string :species
      t.boolean :sprayed_or_neutered
      t.string :pat_name
      t.string :breed
      t.integer :birth_day
      t.integer :birth_month
      t.integer :birth_year
      t.string :gender
      t.boolean :conditions

      t.timestamps
    end
  end
end
