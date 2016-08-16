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

  class LeadRows

    attr_reader :leads

    def initialize(leads)
      @leads = leads
    end

    def price(lead, response = nil)
      if response
        '$' + response.purchase_order.price_string
      else
        responses_with_prices = lead.responses.select { |response| response.price }
        if responses_with_prices.present?
          responses_with_prices.map { |response| '$' + response.purchase_order.price_string }.join(', ')
        else
          '$0.00'
        end
      end
    end

    def clients(lead, response = nil)
      if response
        response.client.official_name
      else
        lead.responses.map(&:client).map(&:official_name).uniq.join(', ')
      end
    end

    def sold_type(lead)
      responses_with_prices = lead.responses.select { |response| response.price }
      if responses_with_prices.present?
        successful_transactions = lead.transaction_attempts.select { |attempt| attempt.success }
        sold_type = successful_transactions.first
        sold_type.nil? ? 'Exclusive' : sold_type.exclusive_selling? ? 'Exclusive' : 'Shared'
      else
        ''
      end
    end

    def rows
      result = []
      leads.each do |lead|
        responses_with_prices = lead.responses.select { |response| response.price }
        if responses_with_prices.present?
          responses_with_prices.each do |response|
            row = LeadRow.new(lead)
            row.price = price(lead, response)
            row.clients = clients(lead, response)
            row.sold_type = sold_type(lead)
            result << row.to_array
          end
        else
          row = LeadRow.new(lead)
          row.price = '$0.00'
          row.clients = clients(lead)
          row.sold_type = ''
          result << row.to_array
        end
      end
      result
    end

  end

  class LeadRow

    attr_reader :lead
    attr_accessor :price, :sold_type, :clients

    def initialize(lead)
      @lead = lead
    end

    def to_array
      [
        lead.id,
        lead.vertical.name,
        lead.site.host,
        lead.visitor_ip,
        lead.first_name,
        lead.last_name,
        lead.zip,
        lead.state,
        lead.email,
        ((lead.details_pets.first.conditions? ? 'TRUE' : 'FALSE') if lead.pet_insurance?),
        lead.times_sold.nil? ? 0 : lead.times_sold,
        price,
        clients,
        sold_type,
        lead.created_at,
        "tel:" + lead.day_phone,
        lead.details_pets.first.try(:pet_name),
        lead.details_pets.first.try(:species),
        lead.details_pets.first.try(:breed),
        ((lead.details_pets.first.spayed_or_neutered? ? 'TRUE' : 'FALSE') if lead.pet_insurance?),
        lead.details_pets.first.try(:birth_month),
        lead.details_pets.first.try(:birth_year),
        lead.details_pets.first.try(:gender),
        lead.visitor.nil? ? '' : lead.visitor.session_hash,
        lead.visitor.nil? ? '' : lead.visitor.referring_url,
        lead.visitor.nil? ? '' : lead.visitor.landing_page,
        lead.visitor.nil? ? '' : lead.visitor.keywords
      ]
    end
  end

  def index
    respond_to do |format|
      format.any(:html, :js) do
        @leads_per_day = statistic.amount_per_day(params[:firstDate], params[:secondDate])
        @leads = statistic.leads(params[:firstDate], params[:secondDate], params[:page] || 1)
        @rows = LeadRows.new(@leads).rows
      end
      format.xls do
        @leads = statistic.leads(params[:firstDate], params[:secondDate])
        Axlsx::Package.new do |axlsx_package|
          axlsx_package.use_shared_strings = true
          axlsx_package.workbook do |wb|
            wb.styles do |style|
              wb.add_worksheet(name:'Report') do |sheet|
                en_titles = I18n.t('reports.lead.columns')
                title_bg_style = style.add_style :bg_color => "bbbbbb",
                                                 :border => { :style => :thin, :color => '000000' }
                sheet.add_row [
                  en_titles[:lead_id],
                  en_titles[:vertical],
                  en_titles[:site],
                  en_titles[:visitor_ip],
                  en_titles[:first_name],
                  en_titles[:last_name],
                  en_titles[:zip_code],
                  en_titles[:state],
                  en_titles[:email],
                  en_titles[:pre_existing],
                  en_titles[:times_sold],
                  en_titles[:po_amount],
                  en_titles[:sold_to],
                  en_titles[:type_of_lead],
                  en_titles[:created],
                  en_titles[:phone],
                  en_titles[:pet_name],
                  en_titles[:species],
                  en_titles[:breed],
                  en_titles[:spayed_or_neutered],
                  en_titles[:month_of_birth],
                  en_titles[:year_of_birth],
                  en_titles[:gender],
                  en_titles[:session_hash],
                  en_titles[:referring_url],
                  en_titles[:landing_page],
                  en_titles[:keyword]
                ], :style => title_bg_style

                LeadRows.new(@leads).rows.each do |row|
                  sheet.add_row(row)
                end
              end
            end
          end
          send_data(axlsx_package.to_stream.read, filename: 'Report.xlsx', type: 'application/xls')
        end
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