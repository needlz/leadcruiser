class ReportsController < ApplicationController

  def index
    @lead = Lead.first
  end

  def refresh
    render json: {
        days: Lead.number_per_day(params[:firstDate], params[:secondDate])
    }
  end
end