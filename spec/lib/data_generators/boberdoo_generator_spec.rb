require 'rails_helper'
require 'data_generators/boberdoo_generator'

RSpec.describe BoberdooGenerator, type: :request do
  let(:lead) { create(:lead, :for_boberdoo) }
  let!(:health_insurance_lead) { create(:health_insurance_lead, lead: lead) }

  it 'returns lead given during instantiation' do
    generator = BoberdooGenerator.new(lead)
    expect(generator.lead).to eq(lead)
  end

  describe '#generate' do
    it 'generates parameters to be sent to Boberdoo' do
      generator = BoberdooGenerator.new(lead)

      expect(generator.generate(true)).to be_present
    end

    it 'generates all required parameters' do
      boberdoo_params = BoberdooGenerator.new(lead).generate(true)

      expect(boberdoo_params[:TYPE]).to eq health_insurance_lead.boberdoo_type
      expect(boberdoo_params[:SRC]).to eq health_insurance_lead.src
      expect(boberdoo_params[:Landing_Page]).to eq health_insurance_lead.landing_page
      expect(boberdoo_params[:Age]).to eq health_insurance_lead.age

    end
  end
end