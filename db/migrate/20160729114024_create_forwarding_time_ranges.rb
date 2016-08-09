class CreateForwardingTimeRanges < ActiveRecord::Migration
  def change
    create_table :forwarding_time_ranges do |t|
      t.string :begin_day, null: false
      t.time :begin_time, null: false
      t.string :end_day, null: false
      t.time :end_time, null: false
      t.string :kind, null: false

      t.timestamps null: false
    end
  end
end
