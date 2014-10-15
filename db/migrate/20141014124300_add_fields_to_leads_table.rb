class AddFieldsToLeadsTable < ActiveRecord::Migration
  def up
    add_column :leads, :times_sold, :integer
    add_column :leads, :total_sale_amount, :float
    add_column :leads, :visitor_id, :integer
  end

  def down
    remove_column :leads, :times_sold
    remove_column :leads, :total_sale_amount
    remove_column :leads, :visitor_id
  end
end
