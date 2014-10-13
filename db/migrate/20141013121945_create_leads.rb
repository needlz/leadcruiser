class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.string :session_hash
      t.integer :site_id
      t.integer :form_id
      t.string :vertical_id
      t.string :integer
      t.integer :leads_details_id
      t.string :first_name
      t.string :last_name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :day_phone
      t.string :evening_phone
      t.string :email
      t.string :best_time_to_call
      t.datetime :birth_date
      t.string :gender

      t.timestamps
    end
  end
end
