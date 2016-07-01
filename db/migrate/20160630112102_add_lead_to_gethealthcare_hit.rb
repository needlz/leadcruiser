class AddLeadToGethealthcareHit < ActiveRecord::Migration
  def change
    add_column :gethealthcare_hits, :lead_id, :integer
  end
end
