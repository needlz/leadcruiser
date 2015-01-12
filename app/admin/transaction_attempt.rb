ActiveAdmin.register TransactionAttempt do


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
  filter  :response,
          :as => :select,
          :collection => Response.select(:id).order(id: :asc).pluck(:id, :id)
  filter  :clients_vertical,
          :as => :select,
          :collection => ClientsVertical.select(:integration_name, :id).uniq.pluck(:integration_name, :id)
  filter :price
  filter :success
  filter :exclusive_selling
  filter :created_at

  index do
    id_column
    column :lead_id
    column "Client Name" do |tr|
      tr.clients_vertical.try(:integration_name)
    end
    column :purchase_order_id
    column :price
    column :weight
    column :success
    column :exclusive_selling
    column :reason
    column :response_id
    column "Created At" do |response|
      unless response.created_at.nil?
        response.created_at.strftime("%Y-%m-%d %H:%M:%S")
      end
    end
  end
end
