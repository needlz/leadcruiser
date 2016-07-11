require 'rails_helper'

RSpec.describe PurchaseOrderQuery, :type => :request do

  include ActionView::Helpers::NumberHelper

  let(:vertical) { create(:vertical) }
  let(:lead) { create(:lead, vertical: vertical) }
  let(:client) { create(:clients_vertical) }

  describe '#initialize' do

    it 'instantiates purchase order builder' do
      query =  PurchaseOrderQuery.new(lead)

      expect(query.exclusive_pos_length).to eq 0
      expect(query.shared_pos_length).to eq 0
      expect(query.times_sold).to eq 0
    end

  end

  describe 'querying purchase orders' do
    let(:query) { PurchaseOrderQuery.new(lead) }
    let(:active_exclusive_purchase_orders) { create_list(:purchase_order,
                                                         2,
                                                         vertical: vertical,
                                                         exclusive: true,
                                                         active: true,
                                                         client_id: client.id,
                                                         states: 'Texas, Colorado, Washington') }
    let(:active_shared_purchase_orders) { create_list(:purchase_order,
                                                      2,
                                                      vertical: vertical,
                                                      exclusive: false,
                                                      active: true,
                                                      client_id: client.id,
                                                      states: 'Texas, Colorado, Washington') }
    let(:inactive_exclusive_purchase_orders) { create_list(:purchase_order,
                                                           2,
                                                           vertical: vertical,
                                                           exclusive: true,
                                                           active: false,
                                                           client_id: client.id,
                                                           states: 'Texas, Colorado, Washington') }
    let(:inactive_shared_purchase_orders) { create_list(:purchase_order,
                                                        2,
                                                        vertical: vertical,
                                                        exclusive: false,
                                                        active: false,
                                                        client_id: client.id,
                                                        states: 'Texas, Colorado, Washington') }

    describe '#exclusive_pos' do
      context 'when purchase orders are active' do
        context 'when there are exclusive and shared purchase orders' do
          before do
            active_exclusive_purchase_orders
            active_shared_purchase_orders
          end

          context 'when purchase order allowed states list includes state of lead' do
            before do
              lead.state = active_exclusive_purchase_orders.first.states_array[0]
              lead.save!
            end

            it 'returns hash with exclusive purchase orders' do
              purchase_orders_hash = {}
              active_exclusive_purchase_orders.each do |purchase_order|
                weight = purchase_order.weight || 0
                price = number_with_precision(purchase_order.price + weight, precision: 2)
                purchase_orders_hash[price.to_s] ||= []
                purchase_orders_hash[price.to_s] << {
                  id: purchase_order.id,
                  client_id: purchase_order.client_id,
                  price: purchase_order.price,
                  real_price: price.to_f
                }
              end

              expect(query.exclusive_pos).to eq(purchase_orders_hash)
            end
          end

          context 'when purchase order allowed states list does not include state of lead' do
            it 'returns empty hash' do
              expect(query.exclusive_pos).to eq({})
            end
          end
        end

        context 'when there are only shared purchase orders' do
          before do
            active_shared_purchase_orders
          end

          it 'returns empty hash' do
            expect(query.exclusive_pos).to eq({})
          end
        end

      end

      context 'when purchase orders are inactive' do
        before do
          inactive_exclusive_purchase_orders
          inactive_shared_purchase_orders
        end

        context 'when there are exclusive and shared purchase orders' do
          it 'returns empty hash' do
            expect(query.exclusive_pos).to eq({})
          end
        end
      end

    end
  end

end
