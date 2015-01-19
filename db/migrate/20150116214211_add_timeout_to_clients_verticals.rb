class AddTimeoutToClientsVerticals < ActiveRecord::Migration
  def change
  	add_column :clients_verticals, :timeout, :integer, :default => 20
  end
end
