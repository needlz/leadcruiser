class LeadsController < ApplicationController

  def create
    Lead.transaction do
      Lead.create(lead_params)
      Visitor.create(visitor_params)
    end

    render json: ''
  end

  private
  def visitor_params
    params.require(:visitor).permit(:site_id, :session_hash, :visitor_ip, :referring_url,
                                    :referring_domain, :landing_page, :keywords, :utm_medium,
                                    :utm_source, :utm_campaign, :utm_term, :utm_content, :location, :browser, :os)
  end

  def lead_params
    params.require(:lead).permit(:session_hash, :site_id, :form_id, :vertical_id, :leads_details_id,
                                 :first_name, :last_name, :address_1, :address_2, :city, :state, :zip,
                                 :day_phone, :evening_phone, :email, :best_time_to_call, :birth_date,
                                 :gender)
  end

end

