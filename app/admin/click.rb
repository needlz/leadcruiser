ActiveAdmin.register Click do

  filter :clients_vertical
  filter :visitor_ip

  index do
    selectable_column
    id_column
    column :visitor_ip
    column "Clients Vertical" do |click|
      click.clients_vertical.try(:integration_name)
    end
    column :clicks_purchase_order_id
    column :status
    column "Price" do |click|
      if click.status == Click::SOLD
        price = 0
        unless click.clicks_purchase_order.price.nil?
          price += click.clicks_purchase_order.price
        end

        weight = 0
        unless click.clicks_purchase_order.weight.nil?
          weight += click.clicks_purchase_order.weight
        end        
        '%.1f' % (price + weight)
      end
    end
    column "Created Date" do |click|
      unless click.created_at.nil?
        click.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
      end
    end
  end

end
