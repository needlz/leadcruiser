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

  task :load_petfirst_dog_mapping => :environment do
    require 'csv'
    CSV.foreach( "var/petfirst_dog.csv", :headers => true) do |row|
      dog_breed = DogBreed.find_by_name(row['our_list'])
      if dog_breed.nil?
        DogBreed.create(name: row['our_list'].gsub("\u00A0", ''))
      end

      ClientDogBreedMapping.create(
        breed_id: DogBreed.find_by_name(row['our_list']).id, 
        integration_name: 'pet_first', 
        name: row['update_action'].gsub("\u00A0", '')
      ) if row['update_action'] != 'x'
    end
  end

  task :load_petfirst_cat_mapping => :environment do
    require 'csv'
    CSV.foreach( "var/petfirst_cat.csv", :headers => true) do |row|
      cat_breed = CatBreed.find_by_name(row['our_list'])
      if cat_breed.nil?
        CatBreed.create(name: row['our_list'].gsub("\u00A0", ''))
      end

      ClientCatBreedMapping.create(
        breed_id: CatBreed.find_by_name(row['our_list']).id, 
        integration_name: 'pet_first', 
        name: row['update_action'].gsub("\u00A0", '')
      ) if row['update_action'] != 'x'

    end
  end

  task :remove_tables => :environment do
    DogBreed.destroy_all
    CatBreed.destroy_all
    ClientDogBreedMapping.destroy_all
    ClientCatBreedMapping.destroy_all
  end

end