class ClicksPurchaseOrderBuilder
	include ActionView::Helpers::NumberHelper

	def po_available_clients(vertical)
    client_list = vertical.clients_verticals.active_to_be_displayed.ordered
    return [] if client_list.empty?

    orders_list = []

    client_list.each do |client|
      purchase_orders = client.clicks_purchase_orders.active_with_tracking_page
      next if purchase_orders.empty?

      price = max_price purchase_orders
      order = most_expensive_order purchase_orders, price
      orders_list.push order
    end

    orders_list
  end

  private

  def max_price purchase_orders
    purchase_orders.map(&:total_price).max
  end

  def most_expensive_order purchase_orders, price
    purchase_orders.detect { |order| order.total_price == price }
  end
end
