class AddForwardingRangeToEditableConfigurations < ActiveRecord::Migration
  def change
    add_column :editable_configurations, :forwarding_interval_minutes, :integer, default: 5

    Date::ABBR_DAYNAMES.each do |day|
      day_prefix = day.downcase
      add_column :editable_configurations, "#{ day_prefix }_forwarding_range_start", :time
      add_column :editable_configurations, "#{ day_prefix }_forwarding_range_end", :time

      add_column :editable_configurations, "#{ day_prefix }_afterhours_range_start", :time
      add_column :editable_configurations, "#{ day_prefix }_afterhours_range_end", :time
    end

  end
end
