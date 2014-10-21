class CreateDogBreeds < ActiveRecord::Migration
  def up
    create_table :dog_breeds do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :dog_breeds
  end
end
