class AddNonforwardingRangeToEditableConfigurations < ActiveRecord::Migration
  def change
    add_column :editable_configurations, :non_forwarding_range_start, :time
    add_column :editable_configurations, :non_forwarding_range_end, :time
  end
end
