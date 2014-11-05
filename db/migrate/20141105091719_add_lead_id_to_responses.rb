class AddLeadIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :lead_id, :integer
  end
end
