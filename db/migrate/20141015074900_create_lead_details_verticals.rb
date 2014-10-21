class CreateLeadDetailsVerticals < ActiveRecord::Migration
  def up
    create_table :leads_details_verticals do |t|
      t.integer :lead_id
      t.integer :detail_id
      t.integer :vertical_id

      t.timestamps
    end
  end

  def down
    drop_table :leads_details_verticals
  end
end
