class AddServiceColumnsToClientsVerticals < ActiveRecord::Migration
  def change
  	add_column :clients_verticals, :service_url, :string
  	add_column :clients_verticals, :request_type, :string
  end
end
