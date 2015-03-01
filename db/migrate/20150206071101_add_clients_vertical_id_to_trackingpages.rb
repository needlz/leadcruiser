class AddClientsVerticalIdToTrackingpages < ActiveRecord::Migration
  def change
  	add_column :tracking_pages, :clients_vertical_id, :integer
  	rename_column :tracking_pages, :page_name, :link
  end
end
