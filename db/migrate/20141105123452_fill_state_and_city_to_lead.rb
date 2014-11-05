class FillStateAndCityToLead < ActiveRecord::Migration
  def up
    transaction do
      Lead.all.each do |lead|
        zip_code = lead.try(:zip_code)
        lead.update_columns(city: zip_code.try(:primary_city), state: zip_code.try(:state))
      end
    end
  end

  def down
    Lead.update_all(city: nil, state: nil)
  end
end
