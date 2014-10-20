class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :domain
      t.string :host
      t.string :site_ip

      t.timestamps
    end
  end
end
