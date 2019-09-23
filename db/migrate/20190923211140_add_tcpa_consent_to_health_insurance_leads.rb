class AddTcpaConsentToHealthInsuranceLeads < ActiveRecord::Migration
  def change
    add_column :health_insurance_leads, :tcpa_consent, :text
  end
end
