require 'rails_helper'
require 'data_generators/pet_premium_generator'

RSpec.describe PetPremiumGenerator, type: :request do

  describe '#generate' do
    let!(:zip_code) { create(:zip_code) }

    it 'contains city and state by zip_code if there is no such in lead' do
      lead = create(:lead)
      data = PetPremiumGenerator.new(lead).generate

      expect(data.include?('NY')).to eq(true)
      expect(data.include?('New York')).to eq(true)
    end

    it 'contains city and state by lead' do
      lead = create(:lead, :with_city_and_state)
      data = PetPremiumGenerator.new(lead).generate

      expect(data.include?('AL')).to eq(true)
      expect(data.include?('Alabama')).to eq(true)
    end

  end

end
