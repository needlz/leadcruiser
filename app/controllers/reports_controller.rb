class ReportsController < ApplicationController

  http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

  def index
    @leads_per_day = statistic.amount_per_day(params[:firstDate], params[:secondDate])
    @leads = statistic.leads(params[:firstDate], params[:secondDate], params[:page] || 1)

    respond_to do |format|
      format.html
      format.js
      format.xls do
        @leads = statistic.leads(params[:firstDate], params[:secondDate])
      end
    end
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