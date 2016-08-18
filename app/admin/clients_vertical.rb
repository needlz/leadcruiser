ActiveAdmin.register ClientsVertical do

  menu priority: 3


  permit_params :vertical_id, :integration_name, :official_name, :active, :weight, :exclusive, :fixed_price, :email, :phone_number,
                :website_url, :request_type, :service_url, :logo, :description, :display, :sort_order, :timeout,
                :lead_forwarding_delay_seconds

  config.filters = false

  index do
    selectable_column
    id_column
    column :vertical_id
    column :integration_name
    column :official_name
    column :active
    column :weight
    column :exclusive
    column :fixed_price
    column :email
    column :phone_number
    column :website_url
    column :request_type
    column :lead_forwarding_delay_seconds
    column :service_url
    column :timeout
    column :sort_order
    column "Thank you page" do |client|
      if client.display
        "Show"
      else
        "Hide"
      end
    end
    column "Logo" do |client|
      if Rails.env.production?
        link_to(image_tag(client.logo.url(:thumb), :height => '30'))
      end
    end
    column "created_at" do |client|
      client.created_at
    end
    actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details", :multipart => true do
      f.input :vertical
      f.input :integration_name
      f.input :official_name
      f.input :active
      f.input :weight
      f.input :exclusive
      f.input :fixed_price
      f.input :email
      f.input :phone_number
      f.input :website_url
      f.input :request_type
      f.input :lead_forwarding_delay_seconds
      f.input :service_url
      f.input :timeout
      f.input :sort_order
      f.input :display
      f.input :description
      f.input :logo, :as => :file, :hint => f.template.image_tag(f.object.logo.url(:thumb))
    end
    f.actions
  end
end
