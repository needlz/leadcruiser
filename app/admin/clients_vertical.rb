ActiveAdmin.register ClientsVertical do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :integration_name, :official_name, :active, :weight, :exclusive, :fixed_price, :email, :phone_number,
                :website_url, :request_type, :service_url, :logo, :description
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  index do
    selectable_column
    id_column
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
    column :service_url
    column "Logo" do |client|
      link_to(image_tag(client.logo.url(:thumb), :height => '30'))
    end
    column :created_at
    actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details", :multipart => true do
      f.input :integration_name
      f.input :official_name
      f.input :active
      f.input :weight
      f.input :exclusive
      f.input :fixed_price
      f.input :email
      f.input :phone_number, :as => :phone
      f.input :website_url, :as => :url
      f.input :request_type
      f.input :service_url
      f.input :description
      f.input :logo, :as => :file, :hint => f.template.image_tag(f.object.logo.url(:thumb))
    end
    f.actions
  end
end
