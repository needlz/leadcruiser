ActiveAdmin.register PurchaseOrder do

  permit_params :vertical_id, :client_name, :state_filter, :pre_conditions, :price, :status, :activated, 
                :max_leads, :daily_leads, :start_date, :expiration_date

  index do
    selectable_column
    id_column
    column :vertical_id
    column :client_name
    column :state_filter
    column :pre_conditions
    column :price
    column :status
    column :activated
    column :max_leads
    column :daily_leads
    column "State Date" do |po|
      unless po.start_date.nil?
        po.start_date.strftime("%Y-%m-%d")
      end
    end
    column "Expiration Date" do |po|
      unless po.expiration_date.nil?
        po.expiration_date.strftime("%Y-%m-%d")
      end
    end

    actions
  end

end
