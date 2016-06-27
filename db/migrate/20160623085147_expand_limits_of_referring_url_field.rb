class ExpandLimitsOfReferringUrlField < ActiveRecord::Migration
  def change
    change_column :visitors, :referring_url, :text
  end
end
