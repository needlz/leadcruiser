class AddForwardingIntervalToEditableConfigurations < ActiveRecord::Migration
  def change
    add_column :editable_configurations, :forwarding_interval_minutes, :integer, default: 5
    rename_column :editable_configurations, :non_forwarding_range_start, :afterhours_range_start
    rename_column :editable_configurations, :non_forwarding_range_end, :afterhours_range_end
  end
end
