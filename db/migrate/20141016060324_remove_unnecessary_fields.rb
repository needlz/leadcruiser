class RemoveUnnecessaryFields < ActiveRecord::Migration
  def change
    remove_column :leads, :integer
    remove_column :leads, :visitor_id
    remove_column :leads, :vertical_id
    remove_column :leads, :leads_details_id
    add_column :leads, :vertical_id, :integer
    Lead.update_all(vertical_id: 1)
  end
end
