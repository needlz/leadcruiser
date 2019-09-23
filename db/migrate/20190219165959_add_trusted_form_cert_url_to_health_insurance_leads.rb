class AddTrustedFormCertUrlToHealthInsuranceLeads < ActiveRecord::Migration
  def change
    add_column :health_insurance_leads, :trusted_form_cert_url, :text
  end
end
