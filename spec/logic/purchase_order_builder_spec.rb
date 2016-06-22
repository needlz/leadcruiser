require 'rails_helper'

RSpec.describe PurchaseOrderBuilder, :type => :request do

  describe '#initialize' do
    let!(:vertical) { create(:vertical) }
    let!(:lead) { create(:lead, vertical: vertical) }

    it 'instantiates purchase order builder' do
      builder =  PurchaseOrderBuilder.new lead

      expect(builder.exclusive_pos_length).to eq 0
      expect(builder.shared_pos_length).to eq 0
      expect(builder.times_sold).to eq 0
    end
  end
end
