class AddClientBreedIdToClientDogBreedMappings < ActiveRecord::Migration
  def change
  	add_column :client_dog_breed_mappings, :client_breed_id, :integer
  	add_column :client_cat_breed_mappings, :client_breed_id, :integer
  end
end
