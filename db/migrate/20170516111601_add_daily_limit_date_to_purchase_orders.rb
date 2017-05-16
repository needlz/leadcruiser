class AddDailyLimitDateToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :daily_limit_date, :date
    PurchaseOrder.update_all(daily_limit_date: Time.current.yesterday)
  end
end
