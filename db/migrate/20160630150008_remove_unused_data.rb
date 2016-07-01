class RemoveUnusedData < ActiveRecord::Migration
  def change
    drop_table :leads_details_verticals
    drop_table :tracking_sites
    remove_columns :clicks, :site_id, :partner_id
    remove_columns :clicks_purchase_orders, :site_id, :redirect_url, :daily_count, :daily_limit
    remove_columns :responses, :client_times_sold, :client_offer_amount, :client_offer_accept, :error_reasons
    remove_column :details_pets, :list_of_conditions
    remove_column :sites, :site_ip
  end
end
