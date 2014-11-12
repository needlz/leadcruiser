class AddLogoToClientVerticals < ActiveRecord::Migration
   def self.up
    change_table :clients_verticals do |t|
      t.attachment :logo
    end
  end

  def self.down
    remove_attachment :clients_verticals, :logo
  end

  def change
    add_attachment :clients_verticals, :logo
    
  	add_column :clients_verticals, :email, :string
  	add_column :clients_verticals, :phone_number, :string
  	add_column :clients_verticals, :website_url, :string
  end
end
