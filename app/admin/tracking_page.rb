ActiveAdmin.register TrackingPage do

  permit_params :clients_vertical_id, :link, :display_order

  filter :clients_vertical

  index do
    selectable_column
    id_column
    column "Clients Vertical" do |page|
      page.clients_vertical.try(:integration_name)
    end
    column :link
    column :display_order

    column "Created Date" do |page|
      unless page.created_at.nil?
        page.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
      end
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :"Clients Vertical" do |page|
        page.clients_vertical.try(:integration_name)
      end
      row :link
      row :display_order

      row "Created Date" do |page|
        unless page.created_at.nil?
          page.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
        end
      end
    end
  end

end
