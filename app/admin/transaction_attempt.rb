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

  index do
    id_column
    column :lead_id
    column "Client Name" do |tr|
      tr.clients_vertical.try(:integration_name)
    end
    column :purchase_order_id
    column :price
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
