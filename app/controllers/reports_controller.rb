class ReportsController < ApplicationController

  http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

  def index
   @leads_per_day = lead_amount_per_day(14.days.ago.to_i, Time.now.to_i)
  end

  def refresh
    render json: {
        days: lead_amount_per_day(params[:firstDate], params[:secondDate])
    }
  end

  private

  def lead_amount_per_day(first_date, last_date)
    Reporting::LeadStatistics.new.amount_per_day(first_date, last_date)
  end

end