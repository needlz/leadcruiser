class CreateClicks < ActiveRecord::Migration
  def change
    create_table :clicks do |t|
    	t.integer :visitor_id
    	t.integer :clients_vertical_id
    	t.integer :site_id
    	t.integer :page_id
    	t.integer :partner_id

    	t.timestamps
    end
  end
end
