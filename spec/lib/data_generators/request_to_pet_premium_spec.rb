require 'rails_helper'
require 'data_generators/request_to_pet_premium'

RSpec.describe RequestToPetPremium, type: :request do

  describe '#generate' do
    let!(:zip_code) { create(:zip_code) }

    it 'contains city and state by zip_code if there is no such in lead' do
      lead = create(:lead)
      data = RequestToPetPremium.new(lead).generate(false)

      expect(data.include?('NY')).to eq(true)
      expect(data.include?('New York')).to eq(true)
    end

    it 'contains city and state by lead' do
      lead = create(:lead, :with_city_and_state)
      data = RequestToPetPremium.new(lead).generate(false)

      expect(data.include?('AL')).to eq(true)
      expect(data.include?('Alabama')).to eq(true)
    end

  end

end