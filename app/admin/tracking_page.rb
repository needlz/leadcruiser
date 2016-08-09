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
      page.created_at
    end

    actions
  end

  form  do |f|
    f.inputs "Tracking Pages" do
      f.input :clients_vertical_id, 
              :as => :select,
              :collection => ClientsVertical.select(:integration_name, :id).uniq.pluck(:integration_name, :id)
      f.input :link
      f.input :display_order
    end

    f.actions
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
        page.created_at
      end
    end
  end

end
