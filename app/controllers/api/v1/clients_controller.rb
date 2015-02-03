class API::V1::ClientsController < ActionController::API
  def create
    cpo = ClicksPurchaseOrder.joins(:clients_vertical)
                            .where('clicks_purchase_orders.active = ?', true)
                            .order("clients_verticals.sort_order ASC")

    unless cpo.nil? && cpo.length != 0                            
      clients = []
      cpo.each do |client|
        clients << JSON[client_to_json(client.clients_vertical)]
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

  def client_to_json(client)
    {
      :integration_name   => client.integration_name,
      :email              => client.email,
      :phone_number       => client.phone_number,
      :website_url        => client.website_url,
      :official_name      => client.official_name,
      :description        => client.description,
      :logo_url           => client.logo.url,
      :sort_order         => client.sort_order,
      :display            => client.display
    }
  end
end