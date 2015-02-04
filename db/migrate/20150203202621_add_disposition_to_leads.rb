class AddDispositionToLeads < ActiveRecord::Migration
  def change
  	add_column :leads, :disposition, :string
  end
end
