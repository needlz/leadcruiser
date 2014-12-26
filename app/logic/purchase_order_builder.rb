class PurchaseOrderBuilder

	attr_accessor :lead, 
								:exclusive_pos, 
								:exclusive_pos_length,
								:shared_pos, 
								:shared_pos_length,
								:exclusive_price_keys, 
								:shared_price_keys

	def initialize(lead)
		@lead = lead
		@exclusive_pos_length = 0
		@shared_pos_length = 0

		@exclusive_pos = purchase_order_list(true)
		@exclusive_price_keys = []
		@exclusive_pos.keys.each do |key|
			@exclusive_price_keys << key.to_i
		end
		@exclusive_price_keys = @exclusive_price_keys.sort {|a,b| b <=> a}

		@shared_pos = purchase_order_list(false)
		@shared_price_keys = []
		@shared_pos.keys.each do |key|
			@shared_price_keys << key.to_i
		end
		@shared_price_keys = @shared_price_keys.sort {|a,b| b <=> a}
		binding.pry		
	end

	def exclusive_pos_length
		@exclusive_pos_length
	end

	def shared_pos_length
		@shared_pos_length
	end

	# Return final purchase order lists
	def next_build
		final_po_list = []

		if @exclusive_pos.length == 0
			final_po_list = get_shared_po_group
		else
			shared_price_sum = 0
			shared_po_group = get_shared_po_group
			shared_po_group.each do |po|
				shared_price_sum += po.real_price
			end

			if shared_price_sum < exclusive_pos[0].real_price
				final_po_list.push shared_price_sum
			else
				final_po_list.push exclusive_pos[0]
			end
		end

		final_po_list
	end

	def next_exclusive_po(current_po, rejected_po_id_list)
		if current_po.nil?
			# Select highest price list
			if @exclusive_price_keys.length == 0
				nil
			end
			highest_price = number_with_precision(@exclusive_price_keys[0], precision: 1, significant: true)
			binding.pry
			same_price_po_list = @exclusive_pos[highest_price]
			# Select randomized PO
			random_po = rand(0..same_price_po_list.length)

			random_po
		else
			selected_po = nil # It is finally selected PO
			if @exclusive_price_keys.length == 0
				return nil
			end
			binding.pry
			# Select selectable price level
			current_price = current_po.real_price
			current_price_idx = 0
			for i in 0..@exclusive_price_keys.length
				if current_price == @exclusive_price_keys[i]
					current_price_idx = i
				end
			end
			binding.pry
			for i in current_price_idx..@exclusive_price_keys.length
				pr = @exclusive_price_keys[i]
				same_price_po_list = @exclusive_pos[pr]
				rejected_po_count = 0
				for j in 0..same_price_po_list.length
					if rejected_po_id_list.include? same_price_po_list[j].id
						rejected_po_count = rejected_po_count + 1
					end
				end

				if rejected_po_count == same_price_po_list.length
					next
				end

				selected = false
				try_count = 0
				while try_count != same_price_po_list.length
					random_po = rand(0..same_price_po_list.length)
					try_count = try_count + 1
					unless rejected_po_id_list.include? random_po.id
						return random_po
					end
				end
			end

			return selected_po
		end
	end

	def next_shared_pos(current_po, rejected_po_id_list)
		if current_idx.nil?

			
			# Get same price list and select by random
			same_price_list = []
		else
		end
	end

	private

	def get_shared_po_group
		if @exclusive_pos.length < @lead.vertical.times_sold.to_i
			@exclusive_pos
		else
			@exclusive_pos[0..@lead.vertical.times_sold.to_i]
		end
	end

	# Get available purchase list by lead
	def purchase_order_list(exclusive)
    pos = PurchaseOrder.where('vertical_id = ? and active = ? and exclusive = ?', 
                                @lead.vertical_id, true, exclusive)
    available_pos = {}
    if pos.nil? || pos.length == 0
      available_pos
    else
      pos.each do |po|
      	# Check client active status
      	client = ClientsVertical.find_by_integration_name(po.client_name)
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

        # available_pos << {
        # 	:id => po.id,
        # 	:client_name => po.client_name,
        # 	:real_price => po.price + po.weight.to_i
        # }
        real_price = po.price + po.weight.to_i
        if available_pos[real_price].nil?
        	available_pos[real_price] = []
        end
       	available_pos[real_price] << {
        	:id => po.id,
        	:client_name => po.client_name,
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