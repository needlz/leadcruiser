class AddDayFiltersToPurchaseOrder < ActiveRecord::Migration
  def change
    Date::DAYNAMES.each do |day_name|
      day = day_name.downcase
      add_column(:purchase_orders, day + '_filter_enabled', :boolean)
      add_column(:purchase_orders, day + '_begin_time', :time)
      add_column(:purchase_orders, day + '_end_time', :time)
    end
  end
end
