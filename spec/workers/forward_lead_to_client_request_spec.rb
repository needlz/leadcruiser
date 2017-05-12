require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ForwardLeadToClientRequest do

  describe '#perform' do
    let(:vertical) { FactoryGirl.create(:vertical, name: Vertical::HEALTH_INSURANCE) }
    let(:lead) { FactoryGirl.create(:lead, vertical: vertical) }
    let(:client) { FactoryGirl.create(:clients_vertical, service_url: 'dummy') }
    let(:purchase_order) { FactoryGirl.create(:purchase_order, client_id: client.id) }
    let!(:request_to_dummy_client_class) {
      Object.const_set("RequestTo#{ client.integration_name.camelize }",
        Class.new do
          LINK = ''

          attr_reader :response

          def initialize(lead); end

          def do_request(exclusive, client);
            'response'
          end

          def success?
            true
          end
        end
      )
    }

    it 'makes request to a client' do
      expect_any_instance_of(request_to_dummy_client_class).to receive(:initialize).with(lead)
      expect_any_instance_of(request_to_dummy_client_class).to receive(:do_request).
        with(RequestToClientGenerator::DEFAULT_EXCLUSIVENESS, client)
      ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
    end

    it 'checks response' do
      expect_any_instance_of(request_to_dummy_client_class).to receive(:initialize).with(lead)
      expect_any_instance_of(request_to_dummy_client_class).to receive(:do_request).
        with(RequestToClientGenerator::DEFAULT_EXCLUSIVENESS, client) { 'response' }
      expect { ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id) }.to change{ Response.count }.from(0).to(1)
    end

    context 'when IOError occurs' do
      before do
        expect_any_instance_of(request_to_dummy_client_class).to receive(:do_request) { raise(Net::ReadTimeout) }
      end

      it 'schedules next try' do
        expect { ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id) }.to(
          change{ ForwardLeadToClientRequest.jobs.size }.from(0).to(1))
      end

      it 'does not increase leads count' do
        expect_any_instance_of(AddLeadsCount).to_not receive(:perform)
        ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
      end
    end

    context 'when request ends successfully' do
      it 'does not schedule next try' do
        expect { ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id) }.to_not(
          change{ ForwardLeadToClientRequest.jobs.size })
      end

      it 'increases leads count' do
        expect_any_instance_of(AddLeadsCount).to receive(:perform)
        ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
      end
    end # when request ends successfully
  end # #perform
end
