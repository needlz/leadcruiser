class ReportsController < ApplicationController

  def index
   @leads_per_day = lead_amount_per_day(14.days.ago.to_i, Time.now.to_i)
   @leads = Reporting::LeadStatistics.new.leads(14.days.ago, Time.now)
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