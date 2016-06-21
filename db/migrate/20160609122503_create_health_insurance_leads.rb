class CreateHealthInsuranceLeads < ActiveRecord::Migration
  def change
    create_table :health_insurance_leads do |t|
      t.integer :lead_id
      t.string :boberdoo_type
      t.text :match_with_partner_id
      t.text :redirect_url
      t.text :src
      t.string :sub_id
      t.string :pub_id
      t.string :optout
      t.string :imbx
      t.string :ref
      t.string :user_agent
      t.string :tsrc
      t.text :landing_page
      t.string :skip_xsl
      t.string :test_lead

      t.string :fpl
      t.integer :age
      t.integer :height_feet
      t.integer :height_inches
      t.integer :weight
      t.string :tobacco_use
      t.string :preexisting_conditions

      t.integer :household_income
      t.integer :household_size
      t.string :qualifying_life_event
      t.string :spouse_gender
      t.integer :spouse_age
      t.integer :spouse_height_feet
      t.integer :spouse_height_inches
      t.integer :spouse_weight
      t.string :spouse_tobacco_use
      t.string :spouse_preexisting_conditions

      t.string :child_1_gender
      t.integer :child_1_age
      t.integer :child_1_height_feet
      t.integer :child_1_height_inches
      t.integer :child_1_weight
      t.string :child_1_tobacco_use
      t.string :child_1_preexisting_conditions

      t.string :child_2_gender
      t.integer :child_2_age
      t.integer :child_2_height_feet
      t.integer :child_2_height_inches
      t.integer :child_2_weight
      t.string :child_2_tobacco_use
      t.string :child_2_preexisting_conditions

      t.string :child_3_gender
      t.integer :child_3_age
      t.integer :child_3_height_feet
      t.integer :child_3_height_inches
      t.integer :child_3_weight
      t.string :child_3_tobacco_use
      t.string :child_3_preexisting_conditions

      t.string :child_4_gender
      t.integer :child_4_age
      t.integer :child_4_height_feet
      t.integer :child_4_height_inches
      t.integer :child_4_weight
      t.string :child_4_tobacco_use
      t.string :child_4_preexisting_conditions

      t.timestamps null: false
    end
  end
end
