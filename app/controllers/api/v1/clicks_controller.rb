class API::V1::ClicksController < ActionController::API
  include ActionView::Helpers::NumberHelper

  def create
    click_param = permit_click_params
    clients_vertical = ClientsVertical.find_by_integration_name(click_param[:client_name])
    click_param[:clients_vertical_id] = clients_vertical.id
    click_param.delete("client_name")

    click = Click.new(click_param)
    if click.save
      # Check purchase order and update
      # If page_id is null, it means clicking on the thank you page.
      # If else, clicking on popup page
      if click_param[:page_id].nil?
        po_list = ClicksPurchaseOrder.where('clients_vertical_id = ? and page_id IS NULL  and active = true', click.clients_vertical_id)

        # Sort by price + weight
        po_list.each do |po|
          po.price = po.weight.to_f + po.price.to_f
        end
        po_list = po_list.sort {|a,b| b <=> a}
        available_po = po_list.try(:first)
        binding.pry
        if check_purchase_order(available_po)
          available_po.daily_count += 1
          available_po.total_count += 1
          available_po.save
        else
          render json: { errors: 'No purchase orders for this client' }, status: :unprocessable_entity and return
        end
      else
      end
      
      render json: { message: 'Click was captured successfully' }, status: :created and return
    else
      render json: { errors: click.error_messages }, status: :unprocessable_entity and return
    end
  end

  private
  
  def permit_click_params
    params.fetch(:click, {}).permit(:visitor_id, :client_name, :site_id, :page_id, :partner_id)
  end

  def check_purchase_order(po)
    if po.nil?
      return false
    end

    # Check Maximum limit
    if !po.total_limit.nil? and po.total_count >= po.total_limit
      return false
    end

    # Check Daily leads limit
    if !po.daily_limit.nil? and po.daily_count >= po.daily_limit
      return false
    end

    # Check Date
    if !po.start_date.nil? and po.start_date > Date.today
      return false
    end

    if !po.end_date.nil? and po.end_date < Date.today
      return false
    end

    return true
  end

end