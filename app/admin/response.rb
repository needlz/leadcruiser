ActiveAdmin.register Response do

  menu priority: 4

  if ActiveRecord::Base.connection.table_exists?('leads')
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
  end

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
      response.created_at
    end
  end
end
