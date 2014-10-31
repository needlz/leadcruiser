class ReportsController < ApplicationController

  http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

  def index
   from = 14.days.ago
   till = Time.now
   @leads_per_day = statistic.amount_per_day(from.to_i, till.to_i)
   @leads = statistic.leads(from.beginning_of_day, till, params[:page])
  end

  def refresh
    render json: {
        days: statistic.amount_per_day(params[:firstDate], params[:secondDate])
    }
  end

  private

  def statistic
    @statistic ||= Reporting::LeadStatistics.new
  end

end