ActiveAdmin.register TransactionAttempt do

  menu priority: 4

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
        response.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M:%S")
      end
    end
  end
end
