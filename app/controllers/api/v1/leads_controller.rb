require 'data_generators/pet_premium_generator'
require 'data_generators/pet_first_generator'
require 'next_client_builder'
require 'data_generator_provider'
require 'data_generator_provider_json'
require 'workers/send_data_worker.rb'
class API::V1::LeadsController  < ActionController::API

  def create
    lead = Lead.new(lead_params)
    pet = lead.details_pets.build(pet_params)

    if lead.save
      render json: { message: 'Lead was created successfully' }, status: :created
      client_verticals = ClientsVertical.where(vertical_id: lead.vertical_id, active: true, exclusive: true).order('id')
      builder = NextClientBuilder.new(lead, client_verticals)
      SendDataWorker.perform_async(lead.id, builder)
      # SendDataWorker.new.perform(lead.id, builder)
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

