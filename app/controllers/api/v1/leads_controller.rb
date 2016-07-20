require 'next_client_builder'
require 'request_to_client_generator'
require 'workers/send_pet_data_worker'
require 'forward_health_insurance_lead'
require 'lead_validation'

class API::V1::LeadsController  < ActionController::API
  include ActionView::Helpers::NumberHelper

  HEALTH_LEAD_TYPES = [RequestToBoberdoo::HEALTH_INSURANCE_TYPE, RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE]

  attr_reader :vertical

  def index
    return handle_health_insurance_lead if health_insurace_lead?
    render json: { errors: 'Unknown type' }, status: :unprocessable_entity
  end

  def create
    health_insurace_lead? ? handle_health_insurance_lead : handle_pet_insurance_lead
  end

  private

  def health_insurace_lead?
     HEALTH_LEAD_TYPES.include?(params[:TYPE])
  end

  def handle_pet_insurance_lead
    error = "Thanks for submitting your information!<br />Check your email for quotes and exciting offers for [pets_name]."

    lead_params = permit_lead_params
    # Get state value from zipcode service
    query_param = {}
    query_param["zipcode"]    = lead_params[:zip]
    query_param["auth-id"]    = ENV["SMARTYSTREETS_AUTH_ID"]
    query_param["auth-token"] = ENV["SMARTYSTREETS_AUTH_TOKEN"]

    state_response = HTTParty.get "https://api.smartystreets.com/zipcode?", query: query_param
    city_and_state = state_response[0]["city_states"]
    if city_and_state.present?
      lead_params[:state] = city_and_state[0]["state_abbreviation"]
      lead_params[:city] = city_and_state[0]["city"]
    end

    @vertical = Vertical.pet_insurance

    lead = Lead.new(lead_params)
    pet = lead.details_pets.build(permit_pet_params)

    if lead.save
      begin
        PetInsuranceLeadValidation.new(lead, pet).validate
      rescue PetInsuranceLeadValidation::Error => validation_error
        return render json: { errors: validation_error.message, other_client: all_po_client_list.to_json},
                      status: :unprocessable_entity
      end

      AutoResponseThankWorker.perform_async(lead.email)
      SendPetDataWorker.new.perform(lead.id)

      # Check Responses table and return with JSON response
      successful_clients_responses = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id)
      if successful_clients_responses.present?

        # Send email to administrator
        SendEmailWorker.perform_async(successful_clients_responses.map(&:id), lead.id)

        # Concatenate JSON Response of other clients list
        response = success_response(lead, successful_clients_responses)

        render json: response, status: :created
      else
        lead.update_attributes :status => Lead::NO_POS
        render json: { errors: error.gsub("[pets_name]", pet["pet_name"]),
                       other_client: all_po_client_list.to_json },
               status: :unprocessable_entity
      end
    else
      render json: { errors: error.gsub("[pets_name]", pet["pet_name"]),
                     other_client: all_po_client_list.to_json },
             status: :unprocessable_entity
    end
  end

  def success_response(lead, clients_responses)
    sold_clients_names = []
    sold_clients = []
    clients_responses.each do |response|
      sold_clients_names << response.client_name
      client = ClientsVertical.find_by_integration_name(response.client_name)
      redirect_url = client.website_url
      # If sold client is Pets Best, return redirect URL
      redirect_url = redirect_url_from_response(client, lead, redirect_url, response)
      sold_clients << JSON[client_to_json(client, redirect_url)]
    end

    # Get other client list by clicks_purchase_order
    clicks_purchase_order_query = ClicksPurchaseOrderQuery.new
    clicks_purchase_orders = clicks_purchase_order_query.orders_of_available_clients(vertical)

    other_clients = []
    clicks_purchase_orders.each do |clicks_purchase_order|
      client_name = clicks_purchase_order.clients_vertical.try(:integration_name)
      sold_to_client = sold_clients_names.include?(client_name)
      other_clients << JSON[client_of_order_to_json(clicks_purchase_order)] unless sold_to_client
    end

    {
      success: true,
      client: sold_clients.to_json,
      other_client: other_clients.to_json
    }
  end

  def redirect_url_from_response(client, lead, redirect_url, response)
    if client.integration_name == ClientsVertical::PETS_BEST
      resp_str = response.response.gsub("=>", ":")
      resp_str = resp_str.gsub("nil", "\"nil\"")
      resp_json = JSON.parse(resp_str)
      redirect_url = client.service_url + "/?" + resp_json["OriginalQuerystring"]
      redirect_url["aqr=true"] = "aqr=false"
      redirect_url["Json=true"] = "Json=false"
    elsif client.integration_name == ClientsVertical::HEALTHY_PAWS
      redirect_url += "/quote/retrievequote?sessionid="
      redirect_url += lead.email
    end
    redirect_url
  end

  def handle_health_insurance_lead
    @vertical = Vertical.health_insurance
    form = HealthInsuranceLeadForm.new(params)
    lead_for_email = nil
    ActiveRecord::Base.transaction do
      lead = Lead.new(form.lead_attributes)

      process_lead_created_by_crawler lead

      if lead.save
        begin
          HealthInsuranceLeadValidation.new(lead).validate
        rescue HealthInsuranceLeadValidation::Error => validation_error
          return render json: { errors: validation_error.message, other_client: all_po_client_list.to_json },
                        status: :unprocessable_entity
        end

        HealthInsuranceLead.create!(form.health_insurance_lead_attributes.merge({ lead_id: lead.id }))

        lead_for_email = lead
        ForwardHealthInsuranceLead.perform(lead) if lead.status.nil?

        render json: {
          success: true,
        }, status: :created
      else
        render json: { errors: lead.error_messages, other_client: all_po_client_list.to_json },
               status: :unprocessable_entity
      end
    end
    send_thank_you_email(lead_for_email)
  end

  def send_thank_you_email(lead)
    return unless lead
    HealthInsuranceMailWorker.perform_async(:thank_you, lead.id)
  end

  def all_po_client_list
    clicks_purchase_order_builder = ClicksPurchaseOrderQuery.new

    all_cpo_clients = clicks_purchase_order_builder.orders_of_available_clients(@vertical)
    
    other_clients = []
    all_cpo_clients.each do |other_cv|
      other_clients << JSON[client_of_order_to_json(other_cv)]
    end

    return other_clients
  end
  
  def client_to_json(client, redirect_url = nil)
    clicks_purchase_order = ClicksPurchaseOrder.find_by('clients_vertical_id = ? and page_id IS NOT NULL and active = true', client.id)
    {
      clients_vertical_id: client.id,
      integration_name: client.integration_name,
      email: client.email,
      phone_number: client.phone_number,
      website_url: client.website_url,
      official_name: client.official_name,
      description: client.description,
      logo_url: client.logo.url,
      sort_order: client.sort_order,
      display: client.display,
      redirect_url: redirect_url,
      page_id: (clicks_purchase_order ? clicks_purchase_order.page_id : 0),
      clicks_purchase_order_id: (clicks_purchase_order ? clicks_purchase_order.id : 0)
    }   
  end

  def client_of_order_to_json(clicks_purchase_order)
    client = clicks_purchase_order.clients_vertical
    {
      clients_vertical_id: client.id,
      integration_name: client.integration_name,
      email: client.email,
      phone_number: client.phone_number,
      website_url: clicks_purchase_order.tracking_page.link,
      official_name: client.official_name,
      description: client.description,
      logo_url: client.logo.url,
      sort_order: client.sort_order,
      display: client.display,
      page_id: clicks_purchase_order.page_id,
      clicks_purchase_order_id: clicks_purchase_order.id
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

  def get_id_from_phone_number phone_number
    number_without_code = phone_number.to_s[3..-1]
    number_without_code.to_i
  end

  def process_lead_created_by_crawler lead
    if lead.test?
      hit_id = get_id_from_phone_number(lead.day_phone)
      hit = GethealthcareHit.find_by_id(hit_id)
      return unless hit
      hit.lead = lead
      hit.save!
    end
  end
end
