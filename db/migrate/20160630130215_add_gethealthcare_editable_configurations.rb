class AddGethealthcareEditableConfigurations < ActiveRecord::Migration
  def change
    add_column :editable_configurations, :gethealthcare_form_threshold_seconds, :integer, default: 20
  end
end
