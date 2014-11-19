class AddSortOrderColumnToClientVerticals < ActiveRecord::Migration
  def change
  	add_column :clients_verticals, :sort_order, :integer
  	add_column :clients_verticals, :display, :boolean, :default => true
  end
end
