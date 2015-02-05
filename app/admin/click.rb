ActiveAdmin.register Click do


filter :clients_vertical

index do
    selectable_column
    id_column
    column "Visitor IP" do |click|
      click.visitor.try(:visitor_ip)
    end
    column "Clients Vertical" do |click|
      click.clients_vertical.try(:integration_name)
    end
    column :site_id
    column :page_id

    column "Created Date" do |click|
      unless click.created_at.nil?
        click.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
      end
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row "Visitor IP" do |click|
        click.visitor.try(:visitor_ip)
      end
      row :"Clients Vertical" do |click|
        click.clients_vertical.try(:integration_name)
      end
      row :site_id
      row :page_id

      row "Created Date" do |click|
        unless click.created_at.nil?
          click.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
        end
      end
    end
  end


end
