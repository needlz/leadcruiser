class CreateZipCodes < ActiveRecord::Migration
  def change
    create_table :zip_codes do |t|
      t.integer :zip
      t.string :primary_city
      t.string :state
      t.string :timezone

      t.timestamps
    end
  end
end
