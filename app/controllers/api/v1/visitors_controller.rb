class API::V1::VisitorsController < ApplicationController

  def create
      visitor = Visitor.new(visitor_params)

      if visitor.save
        render json: visitor, status: :created
      else
        render json: visitor.errors, status: :unprocessable_entity
      end
  end

  private
  def visitor_params
    params.require(:visitor).permit(:site_id, :session_hash, :visitor_ip, :referring_url,
                                    :referring_domain, :landing_page, :keywords, :utm_medium,
                                    :utm_source, :utm_campaign, :utm_term, :utm_content, :location, :browser, :os)
  end

end

