class AddStatusToClicks < ActiveRecord::Migration
  def change
  	add_column :clicks, :status, :string
  end
end
