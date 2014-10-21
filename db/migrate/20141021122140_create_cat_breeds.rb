class CreateCatBreeds < ActiveRecord::Migration
  def up
    create_table :cat_breeds do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :cat_breeds
  end
end
