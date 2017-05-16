require 'rails_helper'

RSpec.describe AddLeadsCount do

  describe '#perform' do
    let(:clients_vertical) { FactoryGirl.create(:clients_vertical, integration_name: integration_name) }
    let(:integration_name) { 'integration_name' }
    let(:purchase_order) { FactoryGirl.create(:purchase_order,
                                              client_id: clients_vertical.id,
                                              daily_leads_count: initial_daily_count,
                                              leads_count_sold: initial_total_count) }

    # context 'when there are responses from today' do
    #   let(:initial_total_count) { 2 }
    #   let(:initial_daily_count) { 1 }
    #   before do
    #     purchase_order
    #     FactoryGirl.create(:transaction_attempt,
    #                        client_id: clients_vertical.id,
    #                        success: true,
    #                        purchase_order_id: purchase_order.id)
    #   end
    #
    #   it 'increases total counter' do
    #     expect(purchase_order.clients_vertical).to be_present
    #     expect{ AddLeadsCount.new(purchase_order).perform }.to(
    #       change{ purchase_order.leads_count_sold }.
    #         from(initial_total_count).
    #         to(initial_total_count + 1)
    #     )
    #   end
    #
    #   it 'increases daily counter' do
    #     expect{ AddLeadsCount.new(purchase_order).perform }.to(
    #       change{ purchase_order.daily_leads_count }.
    #         from(initial_daily_count).
    #         to(initial_daily_count + 1)
    #     )
    #   end
    # end # when there are responses from today
  #
  #   context 'when there are no responses from today' do
  #     let(:initial_total_count) { 3 }
  #     let(:initial_daily_count) { 2 }
  #     before do
  #       purchase_order
  #     end
  #
  #     it 'increases total counter' do
  #       expect{ AddLeadsCount.new(purchase_order).perform }.to(
  #         change{ purchase_order.leads_count_sold }.
  #           from(initial_total_count).
  #           to(initial_total_count + 1)
  #       )
  #     end
  #
  #     it 'does not increases daily counter' do
  #       expect(initial_daily_count).to_not eq(1)
  #       expect{ AddLeadsCount.new(purchase_order).perform }.to change{ purchase_order.daily_leads_count }.from(initial_daily_count).to(1)
  #     end
  #   end # when there are no responses from today
  end # #perform

end
