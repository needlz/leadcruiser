class AddForwardingIntervalToEditableConfigurations < ActiveRecord::Migration
  def change
    add_column :editable_configurations, :forwarding_interval_minutes, :integer, default: 5
  end
end
