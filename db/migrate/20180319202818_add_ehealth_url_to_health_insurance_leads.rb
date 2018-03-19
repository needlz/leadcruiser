class AddEhealthUrlToHealthInsuranceLeads < ActiveRecord::Migration
  def change
    add_column :health_insurance_leads, :ehealth_url, :text
  end
end
