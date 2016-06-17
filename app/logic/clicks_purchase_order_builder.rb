class ClicksPurchaseOrderBuilder
	include ActionView::Helpers::NumberHelper

	def po_available_clients(vertical)
    client_list = ClientsVertical.where('vertical_id = ? AND display = true AND active = true', vertical.id).order(sort_order: :asc)

    # Select highest price by ClientsVertical
    final_po_list = []
    client_list.each do |client|
      same_client_list = ClicksPurchaseOrder.where('clients_vertical_id = ? and page_id IS NOT NULL and active = true', client.id)

      po_by_price = {}
      same_client_list.each do |scl|
        real_price = number_with_precision(scl.price.to_f + scl.weight.to_f, :precision => 2)
        if po_by_price[real_price].nil?
          po_by_price[real_price] = []
        end
        po_by_price[real_price] << scl
      end

      # Sort by price and get high-price purchase order
      price_keys = []
      po_by_price.keys.each do |key|
        price_keys << key
      end
      price_keys = price_keys.sort {|a,b| b.to_f <=> a.to_f}

      unless price_keys.length == 0
        same_price_pos = po_by_price[price_keys[0]]
        if same_price_pos.length > 1
          random = rand(0..same_price_pos.length-1)
          final_po_list.push same_price_pos[random]
        else
          final_po_list.push same_price_pos[0]
          next
        end
      end
    end

    clients = []
    if final_po_list.length != 0                            
      final_po_list.each do |click_po|
        clients << click_po
      end
    end

    return clients
	end
end