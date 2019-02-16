class AddLeadidTokenToHealthInsuranceLeads < ActiveRecord::Migration
  def change
    add_column :health_insurance_leads, :leadid_token, :string
  end
end
