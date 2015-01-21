ActiveAdmin.register Response do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  filter  :lead,
          :as => :select,
          :collection => Lead.select(:id).order(id: :asc).pluck(:id, :id)
  filter  :purchase_order,
          :as => :select,
          :collection => PurchaseOrder.select(:id).order(id: :asc).pluck(:id, :id)
  filter :rejection_reasons
  filter  :client_name,
          :as => :select,
          :collection => ClientsVertical.select(:integration_name, :integration_name).uniq.pluck(:integration_name, :integration_name)
  filter :price
  filter :created_at

  index do
    id_column
    column :lead_id
    column :client_name
    column :response
    column :rejection_reasons
    column :price
    column :purchase_order_id
    column :response_time
    column "Created At" do |response|
      unless response.created_at.nil?
        response.created_at.strftime("%Y-%m-%d %H:%M:%S")
      end
    end
  end
end
