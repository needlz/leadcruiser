class LeadsController < ApplicationController

  def create
    data = Visitor.create(visitor_params)
    render json: data
  end

  private
  def visitor_params
    params.require(:visitor).permit(:site_id, :session_hash, :visitor_ip, :referring_url,
                                    :referring_domain, :landing_page, :keywords, :utm_medium,
                                    :utm_source, :utm_campaign, :utm_term, :utm_content, :location, :browser, :os)
  end
end

