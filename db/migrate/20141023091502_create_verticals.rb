class CreateVerticals < ActiveRecord::Migration
  def change
    create_table :verticals do |t|
      t.string :name
      t.string :next_client

      t.timestamps
    end
  end
end
