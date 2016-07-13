class PurchaseOrderQuery
  include ActionView::Helpers::NumberHelper

  attr_accessor :lead, 
                :exclusive_pos, 
                :exclusive_pos_length,
                :shared_pos, 
                :shared_pos_length,
                :exclusive_price_keys, 
                :shared_price_keys,
                :times_sold

  def initialize(lead)
    @lead = lead
    @exclusive_pos_length = 0
    @shared_pos_length = 0

    init_exclusive_purchase_orders
    init_shared_purchase_orders

    # Init times_sold
    @times_sold = @lead.vertical.times_sold.to_i
  end

  def init_exclusive_purchase_orders
    @exclusive_pos = purchase_orders_by_exclusiveness(true)
    @exclusive_price_keys = []
    @exclusive_pos.keys.each do |key|
      @exclusive_price_keys << number_with_precision(key, precision: 2).to_f
    end
    @exclusive_price_keys = @exclusive_price_keys.sort {|a,b| b <=> a}
  end

  def init_shared_purchase_orders
    @shared_pos = purchase_orders_by_exclusiveness(false)
    @shared_price_keys = []
    @shared_pos.keys.each do |key|
      @shared_price_keys << number_with_precision(key, precision: 2).to_f
    end
    @shared_price_keys = @shared_price_keys.sort {|a,b| b <=> a}
  end

  def next_exclusive_purchase_order(current_purchase_order, rejected_orders_ids)
    if current_purchase_order.nil?
      # Select highest price list
      return nil if @exclusive_price_keys.blank?
      highest_price = number_with_precision(@exclusive_price_keys[0], precision: 2)
      orders_with_highest_price = @exclusive_pos[highest_price.to_s]
      # Select randomized PO
      orders_with_highest_price.sample
    else
      return nil if @exclusive_price_keys.blank?

      # Select selectable price level
      price_of_current_order = current_purchase_order[:real_price]
      index_of_price_of_current_order = 0
      for i in 0..@exclusive_price_keys.length-1
        index_of_price_of_current_order = i if price_of_current_order == @exclusive_price_keys[i]
      end

      for i in index_of_price_of_current_order..@exclusive_price_keys.length-1
        price = number_with_precision(@exclusive_price_keys[i], :precision => 2)
        orders_of_same_price = @exclusive_pos[price]

        non_rejected_orders = orders_of_same_price.reject { |order| rejected_orders_ids.include?(order[:id]) }

        next if non_rejected_orders.empty? # Go to next price

        return non_rejected_orders.sample
      end

      return nil
    end
  end

  def next_shared_purchase_orders(current_purchase_order, rejected_orders_ids, limit)
    returned_pos = []
    total_count = 0
    if current_purchase_order.nil?
      
      # Get same price list and select by random
      if @shared_price_keys.length == 0
        return returned_pos
      end
      
      for i in 0..@shared_price_keys.length-1
        pr = number_with_precision(@shared_price_keys[i], :precision => 2)
        same_price_po_list = @shared_pos[pr]

        same_price_po_list_temp = []
        for j in 0..same_price_po_list.length-1
          same_price_po_list_temp.push same_price_po_list[j]
        end

        # Select available #{times_sold} POs
        while same_price_po_list_temp.length != 0
          random = rand(0..same_price_po_list_temp.length-1)
          random_po = same_price_po_list_temp[random]
          unless returned_pos.include? random_po
            returned_pos.push random_po
            total_count += 1
          end
          same_price_po_list_temp.delete_at random

          if total_count == limit
            return returned_pos
          end
        end
      end

      # Even if the count is less than times_sold, it returns shared_pos
      return returned_pos
    else
      if @shared_price_keys.length == 0
        return returned_pos
      end
      # Select selectable price level
      current_price = current_purchase_order[:real_price]
      current_price_idx = 0
      for i in 0..@shared_price_keys.length-1
        if current_price == @shared_price_keys[i]
          current_price_idx = i
        end
      end

      for i in current_price_idx..@shared_price_keys.length-1
        pr = number_with_precision(@shared_price_keys[i], :precision => 2)
        same_price_po_list = @shared_pos[pr]

        rejected_po_count = 0
        for j in 0..same_price_po_list.length-1
          if rejected_orders_ids.include? same_price_po_list[j][:id]
            rejected_po_count = rejected_po_count + 1 # All POs in this price level are rejected
          end
        end

        if rejected_po_count == same_price_po_list.length
          next # Go to next highest price
        end

        same_price_po_list_temp = []
        for j in 0..same_price_po_list.length-1
          same_price_po_list_temp.push same_price_po_list[j]
        end

        selected = false
        try_count = 0
        while try_count != same_price_po_list.length
          random = rand(0..same_price_po_list_temp.length-1)
          random_po = same_price_po_list_temp[random]
          try_count = try_count + 1
          unless rejected_orders_ids.include? random_po[:id]
            returned_pos.push random_po
          end
          same_price_po_list_temp.delete_at random

          if returned_pos.length == limit
            return returned_pos
          end
        end
      end

      return returned_pos
    end
  end

  private

  # Get available purchase list by lead
  def purchase_orders_by_exclusiveness(exclusive)
    purchase_orders = PurchaseOrder.where('vertical_id = ? and active = ? and exclusive = ?', @lead.vertical_id, true, exclusive)
    available_pos = {}
    if purchase_orders.present?
      purchase_orders.each do |purchase_order|
        # Check client active status
        client = purchase_order.clients_vertical
        next if client.nil? || !client.active
        # Check states
        state = lead.state || lead.try(:zip_code).try(:state)
        if purchase_order.states.present?
          states = purchase_order.states_array
          states.map(&:strip!)
          next if states.present? and !states.include?(state)
        end

        # Check preexisting conditions
        if lead.pet_insurance?
          pet = lead.details_pets.first
          next if purchase_order.preexisting_conditions and purchase_order.preexisting_conditions != pet.conditions
        end

        # Check Maximum leads limit
        if purchase_order.leads_max_limit and purchase_order.leads_count_sold and purchase_order.leads_count_sold >= purchase_order.leads_max_limit
          next
        end

        # Check Daily leads limit
        if purchase_order.leads_daily_limit and purchase_order.daily_leads_count and purchase_order.daily_leads_count >= purchase_order.leads_daily_limit
          next
        end

        # Check Date
        if purchase_order.start_date and purchase_order.start_date > Date.today
          next
        end

        if purchase_order.end_date and purchase_order.end_date < Date.today
          next
        end

        purchase_order.weight = 0 if purchase_order.weight.nil?

        real_price = number_with_precision(purchase_order.price + purchase_order.weight, precision: 2)

        available_pos[real_price] ||= []
        available_pos[real_price.to_s] << {
          id: purchase_order.id,
          client_id: purchase_order.client_id,
          price: purchase_order.price,
          real_price: real_price.to_f
        }

        if exclusive
          @exclusive_pos_length += 1
        else
          @shared_pos_length += 1
        end
      end
    end

    available_pos
  end
end
