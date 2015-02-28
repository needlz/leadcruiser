# ActiveAdmin.register Click do

#   filter :clients_vertical
#   filter :visitor_ip

#   index do
#     selectable_column
#     id_column
#     column :visitor_ip
#     column "Clients Vertical" do |click|
#       click.clients_vertical.try(:integration_name)
#     end
#     column :clicks_purchase_order_id
#     column :page_id
#     column :status
#     column "Price" do |click|
#       if click.status == Click::SOLD
#         price = 0
#         weight = 0
#         price += click.try(:clicks_purchase_order).try(:price).to_f
#         weight += click.try(:clicks_purchase_order).try(:weight).to_f
        
#         '%.2f' % (price + weight)
#       else
#         ''
#       end
#     end
#     column "Created Date" do |click|
#       unless click.created_at.nil?
#         click.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
#       end
#     end
#   end
# end
