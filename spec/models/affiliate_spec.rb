require 'rails_helper'

RSpec.describe Affiliate, type: :model do
  context 'when creating new affiliate without token' do
    it 'should not create' do
      affiliate = Affiliate.new

      expect { affiliate.save! }.to raise_error( ActiveRecord::RecordInvalid,
                                                 "Validation failed: Token can't be blank" )
    end
  end

  context 'when creating affiliate with existing token' do
    let!(:affiliate) { create(:affiliate, token: 'token') }

    it 'should not create' do
      affiliate = Affiliate.new(token:'token')

      expect { affiliate.save! }.to raise_error( ActiveRecord::RecordInvalid,
                                                 "Validation failed: Token has already been taken" )
    end
  end

  context 'when affiliate id used for multiple sites' do
    let!(:affiliate) { create(:affiliate, token: 'token') }
    let!(:site1) { create(:site, affiliate_id: affiliate.id) }
    let!(:site2) { create(:site, affiliate_id: affiliate.id) }

    it 'has many sites' do
      expect(affiliate.sites).to eq [site1, site2]
    end
  end
end
