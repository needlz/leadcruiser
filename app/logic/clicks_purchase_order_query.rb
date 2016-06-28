class ClicksPurchaseOrderQuery
  include ActionView::Helpers::NumberHelper

  def orders_of_available_clients(vertical)
    clients = vertical.clients_verticals.active_to_be_displayed.ordered
    return [] if clients.empty?

    orders = []
    clients.each do |client|
      purchase_orders = client.clicks_purchase_orders.active_with_tracking_page
      next if purchase_orders.empty?

      orders << orders_with_highest_price(purchase_orders)
    end
    orders
  end

  private

  def max_price(purchase_orders)
    purchase_orders.map(&:total_price).max
  end

  def orders_with_price(purchase_orders, price)
    purchase_orders.detect { |order| order.total_price == price }
  end

  def orders_with_highest_price(purchase_orders)
    price = max_price(purchase_orders)
    orders_with_price(purchase_orders, price)
  end
end
