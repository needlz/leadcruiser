ActiveAdmin.register Vertical do

  menu priority: 2

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :name, :times_sold, :next_client
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
  config.filters = false
  
  index do
    id_column
    column :name
    column :times_sold
    column "Created At" do |v|
      v.created_at
    end
    column "Updated At" do |v|
      v.updated_at
    end
    actions
  end
end
