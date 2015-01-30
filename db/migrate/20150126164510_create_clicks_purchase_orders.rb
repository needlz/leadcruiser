class CreateClicksPurchaseOrders < ActiveRecord::Migration
  def change
    create_table :clicks_purchase_orders do |t|
    	t.integer  :clients_vertical_id
    	t.integer  :site_id
    	t.integer  :page_id
    	t.string   :redirect_url
    	t.float    :price
    	t.float    :weight
    	t.boolean  :active
    	t.integer  :total_limit
    	t.integer  :daily_limit
    	t.integer  :total_count, default: 0
    	t.integer  :daily_count, default: 0
        t.date      :start_date
        t.date      :end_date

    	t.timestamps
    end
  end
end
