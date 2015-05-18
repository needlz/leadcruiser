class CrateBlockLists < ActiveRecord::Migration
  def change
    create_table :block_lists do |t|
      t.string :block_ip
      t.boolean :active
      t.text :description

      t.timestamps
    end
  end
end
