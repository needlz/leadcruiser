require 'rails_helper'

RSpec.describe HealthInsuranceLead, type: :model do

  describe 'validations' do
    let(:required_attributes) {
      {
        boberdoo_type: '21',
        src: 'gethealthcare',
        landing_page: '1',
        age: '50'
      }
    }

    it 'validate presence of :boberdoo_type, :src, :landing_page, :age' do
      HealthInsuranceLead.create!(required_attributes)
      required_attributes.keys.each do |required_attribute|
        attributes = required_attributes.except(required_attribute)
        expect { HealthInsuranceLead.create!(attributes) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

end
