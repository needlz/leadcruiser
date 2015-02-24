ActiveAdmin.register ClicksPurchaseOrder do

  permit_params :clients_vertical_id, :weight, :price, :active, :total_limit, :daily_limit, 
                :start_date, :end_date

  filter :clients_vertical
  filter :price
  filter :active
  filter :start_date
  filter :end_date

  index do
    selectable_column
    id_column
    column "Clients Vertical" do |po|
      po.clients_vertical.try(:integration_name)
    end
    column :site_id
    column :page_id
    column :redirect_url
    column :price
    column :weight
    column :active
    column :total_limit
    column :daily_limit
    column :total_count
    column :daily_count
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
    column "Created Date" do |po|
      UTCToPST(po.created_at)
    end
    column "Updated Date" do |po|
      UTCToPST(po.updated_at)
    end

    actions
  end

  form  do |f|
    f.inputs "Clicks Purchase Order" do
      f.input :clients_vertical_id, 
              :as => :select,
              :collection => ClientsVertical.select(:integration_name, :id).uniq.pluck(:integration_name, :id)
      f.input :site_id
      f.input :page_id
      f.input :redirect_url
      f.input :price
      f.input :weight
      f.input :active
      f.input :total_limit
      f.input :daily_limit
      f.input :start_date
      f.input :end_date
    end

    f.actions
  end

end
