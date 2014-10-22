namespace :breeds do
  desc "Load cat and dog breeds into database from var/breeds.csv"
  task :load_default => :environment do
    require 'csv'

    CSV.foreach( "var/breeds.csv", :headers => true ) do |row|
      DogBreed.create(name: row['dog_breed'].gsub("\u00A0", '')) if row['dog_breed']
      CatBreed.create(name: row['cat_breed'].gsub("\u00A0", '')) if row['cat_breed']
    end
  end

  task :load_pet_premium => :environment do
    require 'csv'
    CSV.foreach( "var/pet_premium_breeds.csv", :headers => true ) do |row|
      DogBreed.create(name: row['dog_breed'].gsub("\u00A0", '')) if row['dog_action'] == 'add'
      CatBreed.create(name: row['cat_breed'].gsub("\u00A0", '')) if row['cat_action'] == 'add'
    end
  end

  task :load_mapping => :environment do
    require 'csv'
    CSV.foreach( "var/breeds.csv", :headers => true ) do |row|
      ClientDogBreedMapping.create(breed_id: DogBreed.find_by_name(row['dog_breed']).id, integration_name: 'pet_premium', name: row['dog_map'].gsub("\u00A0", '')) if row['dog_map']
      ClientCatBreedMapping.create(breed_id: CatBreed.find_by_name(row['cat_breed']).id, integration_name: 'pet_premium', name: row['cat_map'].gsub("\u00A0", '')) if row['cat_map']
    end
  end

end