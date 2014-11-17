require 'data_generators/pet_premium_generator'
require 'data_generators/pet_first_generator'
require 'next_client_builder'
require 'data_generator_provider'
require 'workers/send_data_worker.rb'
class API::V1::LeadsController  < ActionController::API

  def create
    lead = Lead.new(lead_params)
    lead.times_sold = 1
    lead.total_sale_amount = 1

    pet = lead.details_pets.build(pet_params)

    if lead.save
      AutoResponseThankWorker.perform_async(lead.email)
      # render json: { :success => true, message: 'Lead was created successfully' }, status: :created
      # client_verticals = ClientsVertical.where(vertical_id: lead.vertical_id, active: true, exclusive: true)
      # builder = NextClientBuilder.new(lead, client_verticals)
      SendDataWorker.new.perform(lead.id)

      # Check Responses table and return with JSON response
      response = Response.find_by_lead_id(lead.id)
      unless response.nil?
        cv = ClientsVertical.find_by_integration_name(response.client_name)
        
        json_response = {
          :integration_name   => cv.integration_name,
          :email              => cv.email,
          :phone_number       => cv.phone_number,
          :website_url        => cv.website_url,
          :official_name      => cv.official_name,
          :description        => cv.description,
          :logo_url           => cv.logo.url
        }.to_json

        render json: { :success => true, :client => json_response}, status: :created
      else
        render json: { errors: "Unable to get response!"}, status: :unprocessable_entity
      end
    else
      render json: { errors: lead.error_messages + pet.error_messages }, status: :unprocessable_entity
    end
  end

  private
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

