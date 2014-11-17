class AddClientNameToResponses < ActiveRecord::Migration
  def change
  	add_column :responses, :client_name, :string
  end
end
