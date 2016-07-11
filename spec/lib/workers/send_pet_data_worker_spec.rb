require 'rails_helper'

RSpec.describe SendPetDataWorker, type: :request do

  let(:pet_vertical) { create(:vertical, name: Vertical::PET_INSURANCE) }
  let(:client) { create(:clients_vertical) }
  let(:lead) { create(:lead, vertical: pet_vertical) }

  describe '#perform' do
    let!(:purchase_order) { create(:purchase_order,
                                   vertical: pet_vertical,
                                   client_id: client.id,
                                   active: true,
                                   exclusive: true) }

    it 'saves response' do
      expect_any_instance_of(RequestToPetPremium).to receive(:perform_http_request) { 'response' }
      expect_any_instance_of(RequestToPetPremium).to receive(:success?) { true }
      expect{ SendPetDataWorker.new.perform(lead.id) }.to change{ Response.count }.from(0).to(1)
    end
  end

end

