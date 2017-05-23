module Reporting
  class LeadRows

    attr_reader :params, :store_filename
    attr_accessor :leads

    def initialize(params = nil, filename = nil)
      @params = params
      @store_filename = filename
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
            row = Reporting::LeadRow.new(lead)
            row.price = price(lead, response)
            row.clients = clients(lead, response)
            row.sold_type = sold_type(lead)
            result << row.to_array
          end
        else
          row = Reporting::LeadRow.new(lead)
          row.price = '$0.00'
          row.clients = clients(lead)
          row.sold_type = ''
          result << row.to_array
        end
      end
      result
    end

    def in_tmp_folder(filename)
      "#{ tmp_dir }/#{ filename }"
    end

    def tmp_dir
      "#{ Rails.root }/tmp/reports"
    end

    def prepare_tmp_dir
      Dir.mkdir(tmp_dir) unless File.exists?(tmp_dir)
    end

    def save_to_file
      self.leads = Reporting::LeadStatistics.new.leads(params[:firstDate], params[:secondDate])
      axlsx_package = Axlsx::Package.new
      axlsx_package.use_shared_strings = true
      axlsx_package.workbook do |wb|
        wb.styles do |style|
          wb.add_worksheet(name: 'Report') do |sheet|
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
                            en_titles[:keyword],
                            en_titles[:ref]
                          ], :style => title_bg_style
            rows.each do |row|
              sheet.add_row(row)
            end
          end
        end
      end
      prepare_tmp_dir
      filepath = in_tmp_folder(store_filename)
      axlsx_package.serialize(filepath)

      ReportsDir.add_report(filepath)
    end

  end
end
