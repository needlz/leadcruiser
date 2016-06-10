require 'rails_helper'

RSpec.describe HealthInsuranceLead, type: :model do

  describe 'validations' do
    it 'validate presence of :boberdoo_type, :src, :landing_page, :age' do
      def attributes_hash(attributes)
        Hash[attributes.map{ |attr| [attr, 1] }]
      end

      required_attributes = [:boberdoo_type, :src, :landing_page, :age]

      HealthInsuranceLead.create!(attributes_hash(required_attributes))
      required_attributes.each do |required_attribute|
        attributes = required_attributes - [required_attribute]
        expect { HealthInsuranceLead.create!(attributes_hash(attributes)) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

end
