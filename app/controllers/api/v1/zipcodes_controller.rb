require 'data_generator_provider'
require 'workers/send_data_worker.rb'

class API::V1::ZipcodesController  < ActionController::API
  include ActionView::Helpers::NumberHelper

  def create
    zip_params = permit_zipcode_params
    # Get state value from zipcode service
    query_param = {}
    query_param["zipcode"]    = zip_params[:zip]
    query_param["auth-id"]    = ENV["SMARTYSTREETS_AUTH_ID"]
    query_param["auth-token"] = ENV["SMARTYSTREETS_AUTH_TOKEN"]
    
    state_response = HTTParty.get "https://api.smartystreets.com/zipcode?", :query => query_param
    if state_response[0]["city_states"].nil?
      render json: { errors: "invalid zipcode" }, status: :unprocessable_entity
    else
      render json: { errors: "", response: state_response}, status: :unprocessable_entity
    end
  end

  def permit_zipcode_params
    params.fetch(:zipcode, {}).permit(:zip)
  end
end