ActiveAdmin.register PurchaseOrder do

  permit_params :vertical_id, :client_name, :weight, :exclusive, :states, :preexisting_conditions, :price, 
                :status, :active, :max_leads, :daily_leads, :start_date, :end_date

  index do
    selectable_column
    id_column
    column :vertical_id
    column :client_name
    column :weight
    column :exclusive
    column :states
    column :preexisting_conditions
    column :price
    column :status
    column :active
    column :leads_max_limit
    column :leads_daily_limit
    column :leads_count_sold
    column :daily_leads_count
    column "Start Date" do |po|
      unless po.start_date.nil?
        po.start_date.strftime("%Y-%m-%d")
      end
    end
    column "End Date" do |po|
      unless po.end_date.nil?
        po.end_date.strftime("%Y-%m-%d")
      end
    end

    actions
  end

  form  do |f|
    f.inputs "Purchase Order" do
      f.input :vertical
      f.input :client_name, 
              :as => :select, 
              :collection => ClientsVertical.select(:integration_name).uniq.pluck(:integration_name, :integration_name).uniq
      f.input :weight
      f.input :exclusive
      f.input :states
      f.input :preexisting_conditions,
              :as => :select
      f.input :price
      f.input :active
      f.input :leads_max_limit
      f.input :leads_daily_limit
      f.input :start_date
      f.input :end_date
    end

    f.actions
  end

end
