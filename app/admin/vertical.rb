ActiveAdmin.register Vertical do


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
    column :name
    column :times_sold
    column "Created At" do |v|
      unless v.created_at.nil?
        v.created_at.strftime("%Y-%m-%d %H:%M:%S")
      end
    end
    column "Updated At" do |v|
      unless v.updated_at.nil?
        v.updated_at.strftime("%Y-%m-%d %H:%M:%S")
      end
    end
    actions
  end
end
