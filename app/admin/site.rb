ActiveAdmin.register Site do

  menu priority: 4

  permit_params :domain, :host

  filter :domain
  filter :host

  index do
    selectable_column
    id_column
    column :domain
    column :host

    column "Created Date" do |site|
      site.created_at
    end

    column :updated_at do |site|
      site.updated_at
    end

    actions
  end
end
