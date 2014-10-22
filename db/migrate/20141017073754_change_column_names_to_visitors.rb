class ChangeColumnNamesToVisitors < ActiveRecord::Migration
  def change
    rename_column :visitors, :refferring_url, :referring_url
    rename_column :visitors, :refferring_domain, :referring_domain
  end
end
