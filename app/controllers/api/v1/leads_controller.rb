require 'data_generators/pet_premium_generator'
require 'data_generators/pet_first_generator'
require 'data_generators/hartville_generator'
require 'data_generators/pets_best_generator'
require 'data_generators/test_success1_generator'
require 'data_generators/test_success2_generator'
require 'data_generators/test_failure_generator'
require 'next_client_builder'
require 'data_generator_provider'
require 'workers/send_data_worker.rb'

class API::V1::LeadsController  < ActionController::API

  def create
    error = "Thanks for submitting your information!<br />Check your email for quotes and exciting offers for [pets_name]."

    lead = Lead.new(lead_params)
    pet = lead.details_pets.build(pet_params)

    # Check duplication for the lead sold
    duplicated = duplicated_lead(lead_params[:email], lead_params[:vertical_id])

    if lead.save

      if duplicated
        lead.update_attributes(:status => Lead::DUPLICATED)

        render json: { errors: "The email address of this lead was duplicated", :other_client => all_client_list.to_json}, status: :unprocessable_entity and return
      end

      AutoResponseThankWorker.perform_async(lead.email, lead.vertical_id)
      SendDataWorker.new.perform(lead.id)

      # Check Responses table and return with JSON response
      response_list = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id)
      if !response_list.nil? && response_list.length != 0
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
          end
          sold_clients << JSON[cv_json(cv, redirect_url)]
        end
        
        other_cvs = ClientsVertical.where('integration_name NOT IN  (?) and display = true', sold_client_name_list).order(sort_order: :asc)
        
        other_clients = []
        other_cvs.each do |other_cv|
          if other_cv.display
            other_clients << JSON[cv_json(other_cv, other_cv.website_url)]
          end
        end

        render json: { 
          :success => true, 
          :client => sold_clients.to_json, 
          :other_client => other_clients.to_json
        }, status: :created
      else
        lead.update_attributes :status => Lead::NO_POS
        render json: { errors: error.gsub("[pets_name]", pet["pet_name"]) , :other_client => all_client_list.to_json}, status: :unprocessable_entity
      end
    else
      render json: { errors: error.gsub("[pets_name]", pet["pet_name"]), :other_client => all_client_list.to_json }, status: :unprocessable_entity
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

  def all_client_list
    other_cvs = ClientsVertical.where('display = true').order(sort_order: :asc)
    
    other_clients = []
    other_cvs.each do |other_cv|
      if other_cv.display
        other_clients << JSON[cv_json(other_cv)]
      end
    end

    return other_clients
  end

  def cv_json(cv, redirect_url=nil)
    {
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

  def lead_params
    params.fetch(:lead, {}).permit(:session_hash, :site_id, :form_id, :vertical_id, :leads_details_id,
                                 :first_name, :last_name, :address_1, :address_2, :city, :state, :zip,
                                 :day_phone, :evening_phone, :email, :best_time_to_call, :birth_date,
                                 :gender, :visitor_ip)
  end

  def pet_params
    params.fetch(:pet, {}).permit(:species, :spayed_or_neutered, :pet_name, :breed, :birth_day, :birth_month,
                                :birth_year, :gender, :conditions)
  end

end

