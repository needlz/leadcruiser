class AddTcpaLanguageToHealthInsuranceLeads < ActiveRecord::Migration
  def change
    add_column :health_insurance_leads, :tcpa_language, :text
  end
end
