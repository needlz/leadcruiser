class API::V1::ClientsController < ActionController::API
  include ActionView::Helpers::NumberHelper

  def create
    clicks_po_builder = ClicksPurchaseOrderBuilder.new
    final_po_list = clicks_po_builder.po_available_clients(Vertical.find(params[:vertical_id]))

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
      :clients_vertical_id => client.id,
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
      :clicks_purchase_order_id  => click_po.id
    }
  end
end