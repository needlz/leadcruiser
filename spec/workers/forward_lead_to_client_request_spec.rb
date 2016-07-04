require 'rails_helper'

RSpec.describe ForwardLeadToClientRequest do

  describe '#perform' do
    let(:lead) { create(:lead) }
    let(:client) { create(:clients_vertical, service_url: 'dummy') }
    let(:purchase_order) { create(:purchase_order, client_id: client.id) }
    let!(:request_to_dummy_client_class) {
      Object.const_set("RequestTo#{ client.integration_name.camelize }",
        Class.new do
          LINK = ''

          attr_reader :response

          def initialize(lead); end

          def do_request(exclusive, client); end
        end
      )
    }

    it 'makes request to a client' do
      expect_any_instance_of(request_to_dummy_client_class).to receive(:initialize).with(lead)
      expect_any_instance_of(request_to_dummy_client_class).to receive(:do_request).
        with(RequestToClientGenerator::DEFAULT_EXCLUSIVENESS, client)
      ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
    end

  end

end
