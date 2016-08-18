require 'axlsx'

class ReportsController < ApplicationController
  http_basic_authenticate_with(name: LOGIN_NAME, password: LOGIN_PASSWORD) if Settings.use_authentication

  before_filter :force_non_ssl_redirect

  def force_non_ssl_redirect
    if request.ssl?
      options = {
        :protocol => 'http://',
        :host     => request.host,
        :path     => request.fullpath,
        :status   => :moved_permanently
      }

      non_secure_url = ActionDispatch::Http::URL.url_for(options)
      flash.keep if respond_to?(:flash)
      redirect_to(non_secure_url, options)
    end
  end

  def index
    respond_to do |format|
      format.any(:html, :js) do
        @leads_per_day = statistic.amount_per_day(params[:firstDate], params[:secondDate])
        @leads = statistic.leads(params[:firstDate], params[:secondDate], params[:page] || 1)
        rows_generator = Reporting::LeadRows.new
        rows_generator.leads = @leads
        @rows = rows_generator.rows
      end
      format.xls do
        redirect_to(action: :temporary_files)
        generate_report
      end
    end
  end

  def refresh
    render json: {
      days: statistic.amount_per_day(params[:firstDate], params[:secondDate])
    }
  end

  def temporary_files
    @records = ReportsDir.s3_objects
  end

  private

  def generate_report
    filename =
      if params[:firstDate] && params[:secondDate]
        "Report #{ Time.current.strftime('%FT%R %Z') } (#{ params[:firstDate] } - #{ params[:secondDate] }).xlsx"
      else
        "Report #{ Time.current.strftime('%FT%R %Z') }.xlsx"
      end
    ReportGenerationJob.perform_later(params, filename)
  end

  def statistic
    @statistic ||= Reporting::LeadStatistics.new
  end

end