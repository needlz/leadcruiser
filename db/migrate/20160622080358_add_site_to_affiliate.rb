class AddSiteToAffiliate < ActiveRecord::Migration
  def change
    add_column :sites, :affiliate_id, :integer
  end
end
