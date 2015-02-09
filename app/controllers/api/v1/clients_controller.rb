class API::V1::ClientsController < ActionController::API
  include ActionView::Helpers::NumberHelper

  def create
    cpo_list = ClicksPurchaseOrder.where('clicks_purchase_orders.active = ? and page_id IS NOT NULL', true)
                                  .group(:clients_vertical_id)
                                  .select(:clients_vertical_id)

    # Select highest price by ClientsVertical
    final_po_list = []
    cpo_list.each do |cpo|
      same_client_list = ClicksPurchaseOrder.where('clients_vertical_id = ? and page_id IS NOT NULL', cpo.clients_vertical_id)

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

    if final_po_list.length != 0                            
      clients = []
      final_po_list.each do |click_po|
        clients << JSON[client_po_to_json(click_po)]
      end

      render json: { 
        :success => true, 
        :clients => clients.to_json 
      }, status: :created and return
    else
      render json: {:errors => "No available clients" }, status: :unprocessable_entity and return
    end
  end

  private 

  def client_po_to_json(click_po)
    client = click_po.clients_vertical
    {
      :integration_name   => client.integration_name,
      :email              => client.email,
      :phone_number       => client.phone_number,
      :website_url        => click_po.tracking_page.link,
      :official_name      => client.official_name,
      :description        => client.description,
      :logo_url           => client.logo.url,
      :sort_order         => client.sort_order,
      :display            => client.display,
      :page_id            => click_po.page_id,
      :purchase_order_id  => click_po.id
    }
  end
end