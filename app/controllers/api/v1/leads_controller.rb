require 'data_generators/pet_premium_generator'
require 'data_generators/pet_first_generator'
require 'data_generators/hartville_generator'
require 'data_generators/pets_best_generator'
require 'next_client_builder'
require 'data_generator_provider'
require 'workers/send_data_worker.rb'

class API::V1::LeadsController  < ActionController::API

  def create

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
      response = Response.find_by_lead_id(lead.id)
      unless response.nil?
        # Update lead
        lead.times_sold = 1
        lead.total_sale_amount = 1
        lead.update_attributes(:status => Lead::SOLD)

        # Concatenate JSON Response of other clients list
        cv = ClientsVertical.find_by_integration_name(response.client_name)
        other_cvs = ClientsVertical.where('integration_name != ? and display = true', response.client_name).order(sort_order: :asc)
        
        json_response = cv_json(cv)

        other_clients = []
        other_cvs.each do |other_cv|
          if other_cv.display
            other_clients << JSON[cv_json(other_cv)]
          end
        end

        render json: { :success => true, :client => json_response.to_json, :other_client => other_clients.to_json}, status: :created
      else
        render json: { errors: "Unable to get response from the client", :other_client => all_client_list.to_json}, status: :unprocessable_entity
      end
    else
      render json: { errors: lead.error_messages + pet.error_messages, :other_client => all_client_list.to_json }, status: :unprocessable_entity
    end
  end

  private

  def duplicated_lead(email, vertical_id)
    
    exist_lead = Lead.where('email = ? and vertical_id = ? and status = ?', email, vertical_id, Lead::SOLD).first
    if exist_lead.nil? || exist_lead.response.nil? || exist_lead.response.client_name == ''
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

  def cv_json(cv)
    {
      :integration_name   => cv.integration_name,
      :email              => cv.email,
      :phone_number       => cv.phone_number,
      :website_url        => cv.website_url,
      :official_name      => cv.official_name,
      :description        => cv.description,
      :logo_url           => cv.logo.url,
      :sort_order         => cv.sort_order,
      :display            => cv.display
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

