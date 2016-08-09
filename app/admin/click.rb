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
      if click.sold?
        price = 0
        weight = 0
        price += click.try(:clicks_purchase_order).try(:price).to_f
        weight += click.try(:clicks_purchase_order).try(:weight).to_f
        
        '%.2f' % (price + weight)
      else
        ''
      end
    end
    column "Created Date" do |click|
      click.created_at
    end
  end
  
end
