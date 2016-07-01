class API::V1::ClicksController < ActionController::API
  include ActionView::Helpers::NumberHelper

  def create
    click_param = permit_click_params

    click = Click.new(click_param)
    if click.save
      if click.page_id.nil? # User clicked deep_link
        po = ClicksPurchaseOrder.where('clients_vertical_id = ?', click.clients_vertical_id)
                                .where('page_id IS NULL').first

        if check_purchase_order(po)
          click.status = Click::SOLD
          click.clicks_purchase_order_id = po.id
          click.save

          po.total_count += 1
          po.save
        else
          render json: { errors: 'No purchase orders for this client' }, status: :unprocessable_entity and return
        end
      else
        # Check duplication of click by visitor_ip and purchase_order_id
        isSold = Click.where(:created_at => Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
                      .where(:status => Click::SOLD)
                      .where(:clients_vertical_id => click.clients_vertical_id )
                      .where(:visitor_ip => click.visitor_ip).first

        if isSold.nil? # This click is first time today
          click.update_attribute(:status, Click::SOLD)

          # Check purchase order and update
          # If page_id is null, it means clicking on the thank you page.
          # If else, clicking on popup page
          po = ClicksPurchaseOrder.find_by_id permit_click_params[:clicks_purchase_order_id]

          if check_purchase_order(po)
            po.total_count += 1
            po.save
          else
            render json: { errors: 'No purchase orders for this client' }, status: :unprocessable_entity and return
          end
        else # This is not first today
          click.update_attribute(:status, Click::DUPLICATED)        
        end
      end
    else
      render json: { errors: click.error_messages }, status: :unprocessable_entity and return
    end

    render json: { message: 'Click was captured successfully' }, status: :created and return
  end

  private
  
  def permit_click_params
    params.fetch(:click, {}).permit(:visitor_ip, :clients_vertical_id, :clicks_purchase_order_id, :page_id)
  end

  def check_purchase_order(po)
    if po.nil?
      return false
    end

    # Check Maximum limit
    if !po.total_limit.nil? and po.total_count >= po.total_limit
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