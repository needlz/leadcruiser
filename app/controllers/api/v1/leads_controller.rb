require 'xml_generator'
class API::V1::LeadsController < ApplicationController

  def create
    lead = Lead.new(lead_params)
    pet = lead.details_pets.build(pet_params)

    if lead.save
      render json: { message: 'Lead was created successfully' }, status: :created
      my_response = XmlGenerator.new(lead).generate
      puts "============================"
      w = HTTParty.post 'http://hart.staging.petpremium.com/lxpHart?', :body => my_response, :headers => {'Content-type' => 'application/xml'}

      puts "--"*26

      puts my_response.inspect
      puts "*"*500
      response_from_client = w.parsed_response['Response'].to_s
      Response.create(response: response_from_client)
      puts w.parsed_response['Response'].inspect

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

