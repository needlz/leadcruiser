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

  csv do
    column :id
    column :site do |lead| lead.site.try(:display_name) end
    column :form_id
    column :vertical do |lead| lead.vertical.name end
    column :visitor_ip
    column :first_name
    column :last_name
    column :state
    column :email
    column :status
    column :times_sold
    column :sold_to do |lead|
      if lead.health_insurance?
        lead.responses.map(&:client).map(&:official_name).uniq.join(', ')
      else
        responses_with_prices = lead.responses.select { |response| response.price }
        if responses_with_prices.present?
          clients = []
          responses_with_prices.each do |response|
            clients << response.client.official_name
          end
          clients.join(', ')
        end
      end
    end
    column :total_sale_amount
    column :disposition
    column :created_at

  end

  index do
    selectable_column
    id_column
    column :site
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
      if lead.health_insurance?
        lead.responses.map(&:client).map(&:official_name).uniq.join(', ')
      else
        responses_with_prices = lead.responses.select { |response| response.price }
        if responses_with_prices.present?
          clients = []
          responses_with_prices.each do |response|
            clients << response.client.official_name
          end
          clients.join(', ')
        end
      end
    end
    column :disposition
    column "Created At" do |lead|
      lead.created_at
    end

    actions :defaults => false do |post|
      link_to "Resend", resend_lead_path(post.id), method: :post 
    end
  end

  controller do

    def scoped_collection
      super.includes(:site, :details_pets, :vertical,  responses: [:client])
    end

  end
end
