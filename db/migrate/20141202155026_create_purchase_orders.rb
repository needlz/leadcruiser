class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.integer  :vertical_id
      t.string   :client_name
      t.integer  :weight
      t.boolean  :exclusive
      t.string   :states
      t.boolean  :preexisting_conditions
      t.float    :price
      t.string   :status
      t.boolean  :active
      t.integer  :leads_max_limit
      t.integer  :leads_daily_limit
      t.integer  :leads_count_sold, default: 0
      t.integer  :daily_leads_count, default: 0

      t.date     :start_date
      t.date     :end_date

      t.timestamps
    end
  end
end
