class CreateEditableConfigurations < ActiveRecord::Migration
  def change
    create_table :editable_configurations do |t|
      t.integer :gethealthcare_form_monitor_delay_minutes, default: 30
    end
  end
end
