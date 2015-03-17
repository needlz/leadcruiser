require 'data_generators/pet_premium_generator'
require 'data_generators/pet_first_generator'
require 'data_generators/hartville_generator'
require 'data_generators/pets_best_generator'
require 'data_generators/healthy_paws_generator'
require 'next_client_builder'
require 'data_generator_provider'
require 'workers/send_data_worker.rb'

class API::V1::LeadsController  < ActionController::API
  include ActionView::Helpers::NumberHelper

  def create
    error = "Thanks for submitting your information!<br />Check your email for quotes and exciting offers for [pets_name]."

    lead_params = permit_lead_params
    # Get state value from zipcode service
    query_param = {}
    query_param["zipcode"]    = lead_params[:zip]
    query_param["auth-id"]    = ENV["SMARTYSTREETS_AUTH_ID"]
    query_param["auth-token"] = ENV["SMARTYSTREETS_AUTH_TOKEN"]

    state_response = HTTParty.get "https://api.smartystreets.com/zipcode?", :query => query_param
    unless state_response[0]["city_states"].nil?
      lead_params[:state] = state_response[0]["city_states"][0]["state_abbreviation"]
      lead_params[:city] = state_response[0]["city_states"][0]["city"]
    end

    lead = Lead.new(lead_params)
    pet = lead.details_pets.build(permit_pet_params)

    # Check duplication for the lead sold
    duplicated = duplicated_lead(lead_params[:email], lead_params[:vertical_id])

    if lead.save

      # If it is duplicated, it would not be sold
      if duplicated
        lead.update_attributes(:status => Lead::DUPLICATED)
        render json: { errors: "The email address of this lead was duplicated", :other_client => all_po_client_list.to_json}, status: :unprocessable_entity and return
      end

      # Testing dispotiion, Test No Sale
      if lead.first_name == Lead::TEST_TERM && lead.last_name == Lead::TEST_TERM
        lead.update_attribute(:disposition, Lead::TEST_NO_SALE)
        SendEmailWorker.perform_async(nil, lead.id)
        render json: { errors: Lead::TEST_NO_SALE, :other_client => all_po_client_list.to_json}, status: :unprocessable_entity and return
      end

      # Profanities Filter : first name, last name, email, pet name
      # filter_txt = [lead.first_name, lead.last_name, lead.email, pet.pet_name].join(' ')
      # if Obscenity.profane?(filter_txt)
        # lead.update_attribute(:disposition, Lead::PROFANITY)
        # SendEmailWorker.perform_async(nil, lead.id)
        # render json: { errors: Lead::PROFANITY, :other_client => all_po_client_list.to_json}, status: :unprocessable_entity and return
      # end

      # Testing dispotiion, Test Sale
      if lead.first_name == "Erik" && lead.last_name == "Needham"
        lead.update_attribute(:disposition, Lead::TEST_SALE)
      end

      AutoResponseThankWorker.perform_async(lead.email)
      SendDataWorker.new.perform(lead.id)

      # Check Responses table and return with JSON response
      response_list = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id)
      if !response_list.nil? && response_list.length != 0

        # Send email to administrator
        response_id_list = []
        for i in 0..response_list.length - 1
          response_id_list << response_list[i].id
        end
        SendEmailWorker.perform_async(response_id_list, lead.id)
        # SendEmailWorker.new.perform(response_list, lead)

        # Concatenate JSON Response of other clients list
        sold_client_name_list = []
        sold_clients = []
        response_list.each do |response|
          sold_client_name_list << response.client_name

          cv = ClientsVertical.find_by_integration_name(response.client_name)
          # If sold client is Pets Best, return redirect URL
          redirect_url = cv.website_url
          if cv.integration_name == ClientsVertical::PETS_BEST
            resp_str = response.response.gsub("=>", ":")
            resp_str = resp_str.gsub("nil", "\"nil\"")
            resp_json = JSON.parse(resp_str)
            # redirect_url = resp_json["QuoteRetrievalUrl"]
            redirect_url = cv.service_url + "/?" + resp_json["OriginalQuerystring"]
            redirect_url["aqr=true"] = "aqr=false"
            redirect_url["Json=true"] = "Json=false"
          elsif cv.integration_name == ClientsVertical::HEALTHY_PAWS
            redirect_url += "/quote/retrievequote?sessionid="
            redirect_url += lead.email
          end
          sold_clients << JSON[cv_json(cv, redirect_url)]
        end

        # Get other client list by clicks_purchase_order        
        clicks_purchase_order_builder = ClicksPurchaseOrderBuilder.new
        all_clients_list = clicks_purchase_order_builder.po_available_clients

        other_clients = []
        all_clients_list.each do |cpo_client|
          unless sold_client_name_list.include? cpo_client.clients_vertical.try(:integration_name)
            other_clients << JSON[cpo_cv_json(cpo_client)]
          end
        end

        render json: { 
          :success => true, 
          :client => sold_clients.to_json, 
          :other_client => other_clients.to_json
        }, status: :created
      else
        lead.update_attributes :status => Lead::NO_POS
        render json: { errors: error.gsub("[pets_name]", pet["pet_name"]) , :other_client => all_po_client_list.to_json}, status: :unprocessable_entity
      end
    else
      render json: { errors: error.gsub("[pets_name]", pet["pet_name"]), :other_client => all_po_client_list.to_json }, status: :unprocessable_entity
    end
  end

  private

  def duplicated_lead(email, vertical_id)
    
    exist_lead = Lead.where('email = ? and vertical_id = ? and status = ?', email, vertical_id, Lead::SOLD).first
    if exist_lead.nil? || exist_lead.responses.nil?
      return false
    else
      return true
    end

    return false
  end 

  def all_po_client_list
    clicks_purchase_order_builder = ClicksPurchaseOrderBuilder.new

    all_cpo_clients = clicks_purchase_order_builder.po_available_clients
    
    other_clients = []
    all_cpo_clients.each do |other_cv|
      other_clients << JSON[cpo_cv_json(other_cv)]
    end

    return other_clients
  end

  def cv_json(cv, redirect_url=nil)
    {
      :clients_vertical_id => cv.id,
      :integration_name   => cv.integration_name,
      :email              => cv.email,
      :phone_number       => cv.phone_number,
      :website_url        => cv.website_url,
      :official_name      => cv.official_name,
      :description        => cv.description,
      :logo_url           => cv.logo.url,
      :sort_order         => cv.sort_order,
      :display            => cv.display,
      :redirect_url       => redirect_url
    }   
  end

  def cpo_cv_json(po_cv)
    client = po_cv.clients_vertical
    {
      :clients_vertical_id => client.id,
      :integration_name   => client.integration_name,
      :email              => client.email,
      :phone_number       => client.phone_number,
      :website_url        => po_cv.tracking_page.link,
      :official_name      => client.official_name,
      :description        => client.description,
      :logo_url           => client.logo.url,
      :sort_order         => client.sort_order,
      :display            => client.display,
      :page_id            => po_cv.page_id,
      :clicks_purchase_order_id  => po_cv.id
    }   
  end
    
  def permit_lead_params
    params.fetch(:lead, {}).permit(:session_hash, :site_id, :form_id, :vertical_id, :leads_details_id,
                                 :first_name, :last_name, :address_1, :address_2, :city, :state, :zip,
                                 :day_phone, :evening_phone, :email, :best_time_to_call, :birth_date,
                                 :gender, :visitor_ip)
  end

  def permit_pet_params   
    params.fetch(:pet, {}).permit(:species, :spayed_or_neutered, :pet_name, :breed, :birth_day, :birth_month,
                                :birth_year, :gender, :conditions)
  end

end

    