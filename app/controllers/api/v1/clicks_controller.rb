class API::V1::ClicksController < ActionController::API

  def create
    click_param = permit_click_params
    clients_vertical = ClientsVertical.find_by_integration_name(click_param[:client_name])
    click_param[:clients_vertical_id] = clients_vertical.id

    click = Click.new(click_param)
    if click.nil?
      render json: { errors: click.error_messages }, status: :unprocessable_entity
    else
      render json: { message: 'Click was captured successfully' }, status: :created
    end
  end

  private
  def permit_click_params
    params.fetch(:click, {}).permit(:visitor_id, :client_name, :site_id, :page_id, :partner_id)
  end

end