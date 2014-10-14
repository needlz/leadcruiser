class AddFieldsToLeadsTable < ActiveRecord::Migration
  def change
    add_column :leads, :times_sold, :integer
    add_column :leads, :total_sale_amount, :float
    add_column :leads, :visitor_id, :integer
  end
end
