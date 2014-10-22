class AddVisitorIpToLeadsTable < ActiveRecord::Migration
  def change
    rename_column :details_pets, :sprayed_or_neutered, :spayed_or_neutered
    add_column :leads, :visitor_ip, :string, default: '127.1.1.1'
  end
end
