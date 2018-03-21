class AddVisitorIdToHealthInsuranceLeads < ActiveRecord::Migration
  def change
    add_column :health_insurance_leads, :visitor_id, :string
  end
end
