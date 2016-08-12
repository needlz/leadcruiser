ActiveAdmin.register Lead do

  permit_params Lead.column_names if ActiveRecord::Base.connection.table_exists?('leads')

  menu priority: 4

  batch_action :resend do |selection|
    Lead.find(selection).each do |lead|
      AdminsController.new.resend_logic(lead)
    end

    redirect_to admin_leads_path
  end

  filter :id
  filter :vertical
  filter :last_name
  filter :state
  filter :email
  filter :preexisting_conditions
  filter :status
  filter :created_at, :as => :date_range

  form do |f|
    inputs do
      Lead.column_names.each do |column_name|
        input column_name
      end
    end
    actions
  end

  index do
    selectable_column
    id_column
    column :site_id
    column :form_id
    column :vertical_id
    column :visitor_ip
    column :last_name
    column :state
    column :email
    column "Pre existing Condition" do |lead|
      if lead.pet_insurance?
        lead.details_pets.first.conditions ? "True" : "False"
      end
    end
    column :times_sold
    column :total_sale_amount
    column :status
    column "Sold To" do |lead|
      client_list = ""
      responses = lead.sold_responses
      unless responses.length == 0
        for i in 0..responses.length - 2
          client = ClientsVertical.where('vertical_id = ? and integration_name = ?', lead.vertical_id, responses[i].client_name).try(:first)
          client_list += client.id.to_s + ", "
        end
        client = ClientsVertical.where(
            'vertical_id = ? and integration_name = ?', 
            lead.vertical_id, 
            lead.sold_responses[responses.length - 1].client_name
          ).try(:first)
        client_list += client.id.to_s
      end
      client_list
    end
    column :disposition
    column "Created At" do |lead|
      lead.created_at
    end

    actions :defaults => false do |post|
      link_to "Resend", resend_lead_path(post.id), method: :post 
    end
  end
end
