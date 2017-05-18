ActiveAdmin.register TransactionAttempt do

  controller do
    def scoped_collection
      TransactionAttempt.all.includes(:lead, :clients_vertical)
    end
  end

  menu priority: 4

  if ActiveRecord::Base.connection.table_exists?('leads')
    filter  :lead_id,
            as: :numeric
    filter  :purchase_order,
            as: :select,
            collection: PurchaseOrder.select(:id).order(id: :asc).pluck(:id, :id)
    filter  :response,
            as: :select,
            collection: Response.select(:id).order(id: :asc).pluck(:id, :id)
    filter  :clients_vertical,
            as: :select,
            collection: ClientsVertical.select(:integration_name, :id).uniq.pluck(:integration_name, :id)
    filter :price
    filter :success
    filter :exclusive_selling
    filter :created_at
  end

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
      response.created_at
    end
  end

  csv do
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
      response.created_at
    end
    column :email do |transaction_attempt|
      transaction_attempt.lead.email
    end
  end

end
