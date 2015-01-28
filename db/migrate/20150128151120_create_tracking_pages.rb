class CreateTrackingPages < ActiveRecord::Migration
  def change
    create_table :tracking_pages do |t|
    	t.string	:page_name
    	t.integer	:display_order

    	t.timestamps
    end
  end
end
