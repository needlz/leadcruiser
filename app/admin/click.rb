ActiveAdmin.register Click do


filter :clients_vertical

index do
    selectable_column
    id_column
    column "Clients Vertical" do |po|
      po.clients_vertical.try(:integration_name)
    end
    column :site_id
    column :page_id

    column "Created Date" do |po|
      unless po.created_at.nil?
        po.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
      end
    end

    actions
  end


end
