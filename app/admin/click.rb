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
    column :page_id
    column :status
    column "Price" do |click|
      if click.status == Click::SOLD
        price = 0
        weight = 0
        unless click.clicks_purchase_order.nil?
          unless click.clicks_purchase_order.price.nil?
            price += click.clicks_purchase_order.price
          end

          unless click.clicks_purchase_order.weight.nil?
            weight += click.clicks_purchase_order.weight
          end        
        end
        
        '%.1f' % (price + weight)
      else
        ''
      end
    end
    column "Created Date" do |click|
      unless click.created_at.nil?
        click.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
      end
    end
  end

  # content title: proc{ I18n.t("active_admin.dashboard") } do

  #   columns do
  #     column do
  #       panel "Properties Registered" do
  #         table_for 1 do |p|
  #           p.column("Total") { "a" }
  #           p.column("Residential") { "B" }
  #           p.column("Commercial") { "C" }
  #         end
  #       end
  #     end

  #     column do
  #       panel "Subscriptions" do
  #         table_for 1 do |s|
  #           s.column("Trial") { "1" }
  #           s.column("Standard") { "2" }
  #           s.column("Pro") { "3" }
  #           s.column("Enterprise") { "4" }
  #         end
  #       end
  #     end
  #   end
  # end

  # controller do
  #   def index
  #     @clicks = Click.all
  #   end
  # end

end
