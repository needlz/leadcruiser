require 'rails_helper'

RSpec.describe RequestToClientGenerator do

  let(:pet_vertical) { create(:vertical, name: Vertical::PET_INSURANCE) }
  let(:client) { create(:clients_vertical) }
  let(:lead) { create(:lead, vertical: pet_vertical) }

  describe '#send_data' do
    let!(:purchase_order) { create(:purchase_order,
                                   vertical: pet_vertical,
                                   client_id: client.id,
                                   active: true,
                                   exclusive: true) }
    let(:request_generator) { RequestToClientGenerator.new(lead, client) }

    context 'when IOError occurs' do
      before do
        expect_any_instance_of(RequestToClient).to receive(:do_request) { raise(IOError) }
      end

      it 'creates response' do
        expect(request_generator.send_data).to eq 'IOError'
      end
    end

    context 'when timeout error occurs' do
      before do
        expect_any_instance_of(RequestToClient).to receive(:do_request) { raise(Net::ReadTimeout) }
      end

      it 'creates response' do
        expect(request_generator.send_data).to eq 'Timeout'
      end
    end

  end

end

