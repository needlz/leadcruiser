require 'rails_helper'

RSpec.describe Site, :type => :model do
  describe 'create site with affiliate id' do
    let!(:affiliate) { create(:affiliate, token: 'token') }
    let!(:site) { create(:site, affiliate_id: affiliate.id) }

    it 'belongs to affiliate' do
      expect(site.affiliate).to eq affiliate
    end
  end
end
