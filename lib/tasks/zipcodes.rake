namespace :zipcodes do
  desc "Load zipcodes into database from var/zip_code_database.csv"
  task :load => :environment do
    require 'csv'

    CSV.foreach( "var/zip_code_database.csv", :headers => true ) do |row|
      ZipCode.create(
        :zip          => row['zip'],
        :primary_city => row['primary_city'],
        :state        => row['state'],
        :timezone     => row['timezone']
      )
    end
  end
end