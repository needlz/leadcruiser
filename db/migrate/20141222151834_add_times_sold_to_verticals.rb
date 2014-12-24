class AddTimesSoldToVerticals < ActiveRecord::Migration
  def change
  	add_column :verticals, :times_sold, :integer
  end
end
