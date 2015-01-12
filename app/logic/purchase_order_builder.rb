class PurchaseOrderBuilder
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

		# Init exclusive_po list, price keys and legnth
		@exclusive_pos = purchase_order_list(true)
		@exclusive_price_keys = []
		@exclusive_pos.keys.each do |key|
			@exclusive_price_keys << key.to_i
		end
		@exclusive_price_keys = @exclusive_price_keys.sort {|a,b| b <=> a}

		# Init shared_po list, price keys and legnth
		@shared_pos = purchase_order_list(false)
		@shared_price_keys = []
		@shared_pos.keys.each do |key|
			@shared_price_keys << key.to_i
		end
		@shared_price_keys = @shared_price_keys.sort {|a,b| b <=> a}

		# Init times_sold
		@times_sold = @lead.vertical.times_sold.to_i
	end

	def exclusive_pos_length
		@exclusive_pos_length
	end

	def shared_pos_length
		@shared_pos_length
	end

	def next_exclusive_po(current_po, rejected_po_id_list)
		if current_po.nil?
			# Select highest price list
			if @exclusive_price_keys.length == 0
				return nil
			end
			highest_price = number_with_precision(@exclusive_price_keys[0], :precision => 1)
			same_price_po_list = @exclusive_pos[highest_price]
			# Select randomized PO
			random = rand(0..same_price_po_list.length-1)
			same_price_po_list[random]
		else
			if @exclusive_price_keys.length == 0
				return nil
			end
			# Select selectable price level
			current_price = current_po[:real_price]
			current_price_idx = 0
			for i in 0..@exclusive_price_keys.length-1
				if current_price == @exclusive_price_keys[i]
					current_price_idx = i
				end
			end

			for i in current_price_idx..@exclusive_price_keys.length-1
				pr = number_with_precision(@exclusive_price_keys[i], :precision => 1)
				same_price_po_list = @exclusive_pos[pr]

				rejected_po_count = 0
				for j in 0..same_price_po_list.length-1
					if rejected_po_id_list.include? same_price_po_list[j][:id]
						rejected_po_count = rejected_po_count + 1 # All POs in this price level are rejected
					end
				end

				if rejected_po_count == same_price_po_list.length
					next # Go to next highest price
				end

				selected = false
				try_count = 0
				while try_count != same_price_po_list.length
					random = rand(0..same_price_po_list.length-1)
					random_po = same_price_po_list[random]
					try_count = try_count + 1
					unless rejected_po_id_list.include? random_po[:id]
						return random_po
					end
				end
			end

			return nil
		end
	end

	def next_shared_pos(current_po, rejected_po_id_list, limit)
		returned_pos = []
		total_count = 0
		if current_po.nil?
			
			# Get same price list and select by random
			if @shared_price_keys.length == 0
				return returned_pos
			end
			
			for i in 0..@shared_price_keys.length-1
				pr = number_with_precision(@shared_price_keys[i], :precision => 1)
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
			current_price = current_po[:real_price]
			current_price_idx = 0
			for i in 0..@shared_price_keys.length-1
				if current_price == @shared_price_keys[i]
					current_price_idx = i
				end
			end

			for i in current_price_idx..@shared_price_keys.length-1
				pr = number_with_precision(@shared_price_keys[i], :precision => 1)
				same_price_po_list = @shared_pos[pr]

				rejected_po_count = 0
				for j in 0..same_price_po_list.length-1
					if rejected_po_id_list.include? same_price_po_list[j][:id]
						rejected_po_count = rejected_po_count + 1 # All POs in this price level are rejected
					end
				end

				if rejected_po_count == same_price_po_list.length
					next # Go to next highest price
				end

				selected = false
				try_count = 0
				while try_count != same_price_po_list.length
					random = rand(0..same_price_po_list.length-1)
					random_po = same_price_po_list[random]
					try_count = try_count + 1
					unless rejected_po_id_list.include? random_po[:id]
						returned_pos.push random_po
					end

					if returned_pos.length == @times_sold
						return returned_pos
					end
				end
			end

			return returned_pos
		end
	end

	private

	# Get available purchase list by lead
	def purchase_order_list(exclusive)
    pos = PurchaseOrder.where('vertical_id = ? and active = ? and exclusive = ?', @lead.vertical_id, true, exclusive)
    available_pos = {}
    if pos.nil? || pos.length == 0
      available_pos
    else
      pos.each do |po|
      	# Check client active status
      	client = po.clients_vertical
      	if client.nil? || !client.active
      		next
      	end
        # Check states
        state = lead.state || lead.try(:zip_code).try(:state)
        unless po.states.nil?
          state_filter_array = po.states.split(/,/)
          # Remove whitespace in the code
          for i in 0..state_filter_array.length-1
            state_filter_array[i] = state_filter_array[i].strip
          end
          if state_filter_array.length > 0 and !state_filter_array.include? state
            next
          end
        end

        # Check preexisting conditions
        pet = lead.details_pets.first
        if !po.preexisting_conditions.nil? and po.preexisting_conditions != pet.conditions
          next
        end

        # Check Maximum leads limit
        if !po.leads_max_limit.nil? and po.leads_count_sold >= po.leads_max_limit
          next
        end

        # Check Daily leads limit
        if !po.leads_daily_limit.nil? and po.daily_leads_count >= po.leads_daily_limit
          next
        end

        # Check Date
        if !po.start_date.nil? and po.start_date > Date.today
          next
        end

        if !po.end_date.nil? and po.end_date < Date.today
          next
        end

        real_price = (po.price + po.weight.to_i).to_s
        if available_pos[real_price].nil?
        	available_pos[real_price] = []
        end
       	available_pos[real_price] << {
        	:id => po.id,
        	:client_id => po.client_id,
        	:real_price => po.price + po.weight.to_i
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