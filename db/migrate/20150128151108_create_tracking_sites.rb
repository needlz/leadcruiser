class CreateTrackingSites < ActiveRecord::Migration
  def change
    create_table :tracking_sites do |t|
    	t.string 	:site_name
    	t.integer :display_order

    	t.timestamps
    end
  end
end
