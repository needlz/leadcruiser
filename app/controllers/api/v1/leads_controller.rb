class API::V1::LeadsController < ApplicationController
  before_filter :checking_visitor

  def create
    lead = current_visitor.leads.new(lead_params)

    if lead.save
      render json: lead, status: :created
    else
      render json: lead.errors, status: :unprocessable_entity
    end
  end

  private
  def lead_params
    params.require(:lead).permit(:session_hash, :site_id, :form_id, :vertical_id, :leads_details_id,
                                 :first_name, :last_name, :address_1, :address_2, :city, :state, :zip,
                                 :day_phone, :evening_phone, :email, :best_time_to_call, :birth_date,
                                 :gender)
  end

  def pet_params
    params.require(:pet).permit(:species, :spayed_or_neutered, :pet_name, :breed, :birth_day, :birth_month,
                                :birth_year, :gender, :conditions)
  end

  def current_visitor
    @visitor ||= Visitor.find_by_session_hash(lead_params[:session_hash])
  end

  def checking_visitor
    unless current_visitor
      respond_with_error("There are no visitor connected with this lead by session_hash", :unprocessable_entity)
    end
  end
end

