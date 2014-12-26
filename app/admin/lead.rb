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
    column :site_id
    column :form_id
    column :vertical_id
    column :visitor_ip
    column :first_name
    column :last_name
    column :state
    column :zip
    column :day_phone
    column :email
    column "Pre existing Condition" do |lead|
      if lead.details_pets.first.conditions
        "True"
      else
        "False"
      end
    end
    column :times_sold
    column :total_sale_amount
    column :status
    column "Rejection Reason" do |lead|
      if lead.latest_response.nil?
        ""
      else
        lead.latest_response.rejection_reasons
      end
    end
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
