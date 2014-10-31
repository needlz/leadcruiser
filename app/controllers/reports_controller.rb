class ReportsController < ApplicationController

  def index
   @leads_per_day = lead_amount_per_day(14.days.ago.to_i, Time.now.to_i)
   @page = params[:page] || 1
   @leads = Reporting::LeadStatistics.new.leads(14.days.ago.beginning_of_day, Time.now, @page)
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