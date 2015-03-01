class ReportsController < ApplicationController

  http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

  def index
    respond_to do |format|
      format.any(:html, :js) do
        @leads_per_day = statistic.amount_per_day(params[:firstDate], params[:secondDate])
        @leads = statistic.leads(params[:firstDate], params[:secondDate], params[:page] || 1)
      end
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