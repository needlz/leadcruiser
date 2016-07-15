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

    describe '#exclusive_price_keys' do
      before do
        lead.state = 'Texas'
        lead.save!
      end

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

          it 'returns proces of exclusive purchase orders' do
            prices = query.exclusive_pos.keys.map(&:to_f)
            expect(query.exclusive_price_keys).to match_array prices
          end
        end
      end

    end

    describe '#next_exclusive_purchase_order' do
      before do
        lead.state = 'Texas'
        lead.save!
      end

      context 'when current_purchase_order is nil' do
        context 'when there is no exclusive purchase orders' do
          it 'returns nil' do
            rejected_orders_ids = []
            expect(query.next_exclusive_purchase_order(nil, rejected_orders_ids)).to be_nil
          end
        end

        context 'when there are exclusive purchase orders' do
          before do
            active_exclusive_purchase_orders
            active_shared_purchase_orders
          end

          it 'returns random purchase order with highest price' do
            highest_price = active_exclusive_purchase_orders.map(&:price).max
            rejected_orders_ids = []
            expect(query.next_exclusive_purchase_order(nil, rejected_orders_ids)[:price]).to eq highest_price
          end
        end
      end

      context 'when current_purchase_order is present' do
        orders_count = 5
        let(:active_exclusive_purchase_orders) { create_list(:purchase_order,
                                                             orders_count,
                                                             vertical: vertical,
                                                             exclusive: true,
                                                             active: true,
                                                             client_id: client.id,
                                                             states: 'Texas, Colorado, Washington') }
        let(:orders_from_expensive_to_cheap) { active_exclusive_purchase_orders.sort { |a, b| a.price <=> b.price }.reverse }
        let(:current_purchase_order) { orders_from_expensive_to_cheap[orders_count / 2] }
        let(:current_order_index) { orders_from_expensive_to_cheap.index(current_purchase_order) }

        context 'when there are exclusive purchase orders' do
          before do
            active_exclusive_purchase_orders
            active_shared_purchase_orders
          end

          it 'returns random non-rejected purchase order with highest price' do
            rejected_orders_ids = active_exclusive_purchase_orders.map(&:id) - [orders_from_expensive_to_cheap[current_order_index + 1].id]
            price = number_with_precision(orders_from_expensive_to_cheap[current_order_index + 1].price, precision: 2)
            expect(query.next_exclusive_purchase_order(current_purchase_order, rejected_orders_ids)[:price]).to eq(price.to_f)
          end
        end

        context 'when there is no exclusive purchase orders' do
          it 'returns nil' do
            rejected_orders_ids = []
            expect(query.next_exclusive_purchase_order(create(:purchase_order), rejected_orders_ids)).to be_nil
          end
        end
      end

    end

  end

end
