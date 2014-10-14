class API::V1::LeadsController < ApplicationController

  def create
    lead = Lead.new(lead_params)

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

end

