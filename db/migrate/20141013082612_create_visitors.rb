class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors do |t|
      t.string :session_hash
      t.integer :site_id
      t.string :visitor_ip
      t.string :refferring_url
      t.string :refferring_domain
      t.string :landing_page
      t.string :keywords
      t.string :utm_medium
      t.string :utm_source
      t.string :utm_campaign
      t.string :utm_term
      t.string :utm_content
      t.string :location
      t.string :browser
      t.string :os

      t.timestamps
    end
  end
end
