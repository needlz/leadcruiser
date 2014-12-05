ActiveAdmin.register Lead do


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
  batch_action :resend do |selection|
    Lead.find(selection).each do |lead|
      AdminsController.new.resend_logic(lead)
    end

    redirect_to admin_leads_path
  end

  index do
    selectable_column
    id_column
    column :session_hash
    column :site_id
    column :form_id
    column :vertical_id
    column :visitor_ip
    column :first_name
    column :last_name
    column :address_1
    column :address_2
    column :city
    column :state
    column :zip
    column :day_phone
    column :email
    column :times_sold
    column :total_sale_amount
    column :status
    column "Created At" do |lead|
      unless lead.created_at.nil?
        lead.created_at.strftime("%Y-%m-%d %H:%M:%S")
      end
    end
    column "Updated At" do |lead|
      unless lead.updated_at.nil?
        lead.updated_at.strftime("%Y-%m-%d %H:%M:%S")
      end
    end

    actions :defaults => false do |post|
      link_to "Resend", resend_lead_path(post.id), method: :post 
    end
  end
end