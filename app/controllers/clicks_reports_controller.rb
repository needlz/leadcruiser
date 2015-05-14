require 'axlsx'

class ClicksReportsController < ApplicationController

  http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

  def index
    clients_verticals = ClientsVertical.where('active = true').order(:vertical_id)

    date_from = nil
    date_to = nil
    unless params[:date].nil?
      date_from = params[:date]["from_date"]
      date_to = params[:date]["to_date"]
    else
      date_from = params["from_date"]
      date_to = params["to_date"]
    end
    if date_from.nil? || date_from == ""
      date_from = "0001-01-01"
    end

    if date_to.nil? || date_to == ""
      date_to = "9999-12-31"
    end

    @clients_verticals_clicks = []
    clients_verticals.each do |cv|
      clicks = Click.where('clients_vertical_id = ?', cv.id)
                    .where(:created_at => date_from.to_date.in_time_zone("Pacific Time (US & Canada)").beginning_of_day..date_to.to_date.in_time_zone("Pacific Time (US & Canada)").end_of_day)
      
      total_info = {}
      total_clicks = 0
      sold_clicks = 0
      total_price = 0
      clicks.each do |ck|
        total_clicks += 1;
        if ck.status == Click::SOLD
          sold_clicks += 1;

          price = 0
          weight = 0
          unless ck.clicks_purchase_order.nil?
            price = ck.clicks_purchase_order.price.to_f
            weight = ck.clicks_purchase_order.weight.to_f
          end
          total_price += price + weight
        end
      end

      total_info["vertical_id"] = cv.vertical_id
      total_info["clients_vertical_id"] = cv.id
      total_info["integration_name"] = cv.official_name
      total_info["total_clicks"] = total_clicks
      total_info["sold_clicks"] = sold_clicks
      total_info["total_price"] = '%.2f' % total_price

      @clients_verticals_clicks.push total_info
    end

    # @ready_pagination = WillPaginate::Collection.create(3, 30, clients_verticals_clicks.length) do |pager|
    #   pager.replace clients_verticals_clicks
    # end
    @clients_verticals_clicks_paging = @clients_verticals_clicks.paginate(:page => params[:page] || 1, :per_page => 10)
    #@clients_verticals_clicks = @ready_pagination.paginate(:page => params[:page], :per_page => 3)
    respond_to do |format|
      format.any(:html, :js) do
        @clients_verticals_clicks_paging
      end
      format.xls do
        
        Axlsx::Package.new do |axlsx_package|
          axlsx_package.use_shared_strings = true
          start_time = Time.now
          axlsx_package.workbook do |wb|
            wb.styles do |style|
              wb.add_worksheet(name:'Report') do |sheet|

                en_titles = I18n.t('reports.clients_vertical_report.columns')
                title_bg_style = style.add_style :bg_color => "bbbbbb", 
                                                :border => { :style => :thin, :color => '000000' }

                sheet.add_row [
                  en_titles[:vertical_id],
                  en_titles[:client_name],
                  en_titles[:total_clicks],
                  en_titles[:sold_clicks], 
                  en_titles[:total_price], 
                  en_titles[:date_from], 
                  en_titles[:date_to]
                ], :style => title_bg_style

                @clients_verticals_clicks.each do |click|
                  sheet.add_row [
                    click["vertical_id"],
                    click["integration_name"],
                    click["total_clicks"],
                    click["sold_clicks"],
                    click["total_price"],
                    params["from_date"],
                    params["to_date"]
                  ]
                end
              end
            end
          end

          send_data axlsx_package.to_stream.read, :filename => "ClicksReport.xlsx"
        end
      end
    end
  end

  def by_client
    date_from = nil
    date_to = nil
    unless params[:date].nil?
      date_from = params[:date]["from_date"]
      date_to = params[:date]["to_date"]
    else
      date_from = params["from_date"]
      date_to = params["to_date"]
    end
    if date_from.nil? || date_from == ""
      date_from = "0001-01-01"
    end

    if date_to.nil? || date_to == ""
      date_to = "9999-12-31"
    end

    @clients_vertical = ClientsVertical.find params["clients_vertical_id"]
    visitor_ip_list = Click.where('clients_vertical_id = ?', params["clients_vertical_id"])
                            .where(:created_at => date_from.to_date.in_time_zone("Pacific Time (US & Canada)").beginning_of_day..date_to.to_date.in_time_zone("Pacific Time (US & Canada)").end_of_day)
                            .group('visitor_ip')
                            .order('visitor_ip')
                            .select("visitor_ip")

    @visitor_clicks = []
    visitor_ip_list.each do |visitor|
      click_list = Click.where('clients_vertical_id = ? and visitor_ip = ?', params["clients_vertical_id"], visitor.visitor_ip)
                        .where(:created_at => date_from.to_date.in_time_zone("Pacific Time (US & Canada)").beginning_of_day..date_to.to_date.in_time_zone("Pacific Time (US & Canada)").end_of_day)
                        .order(created_at: :desc)

      # group by date (clicks per date, price per date)                        
      hash_by_date = {}
      click_list.each do |click|
        date = click.created_at.in_time_zone("Pacific Time (US & Canada)")
        unless hash_by_date.has_key?(date.strftime("%F"))
          hash_by_date[date.strftime("%F")] = []
        end

        hash_by_date[date.strftime("%F")] << click
      end

      hash_by_date_keys = hash_by_date.keys
      for i in 0..hash_by_date_keys.length-1
        date_key = hash_by_date_keys[i]

        sold_clicks = 0
        duplicated_clicks = 0
        sold_price = 0

        click_list_by_date = hash_by_date[date_key]
        for j in 0..click_list_by_date.length-1
          if click_list_by_date[j].status == Click::SOLD
            sold_clicks += 1
            sold_price += click_list_by_date[j].try(:clicks_purchase_order).try(:price).to_f
            sold_price += click_list_by_date[j].try(:clicks_purchase_order).try(:weight).to_f
          else
            duplicated_clicks += 1
          end
        end

        visitor_click = {}
        visitor_click["ip"]   = visitor.visitor_ip
        visitor_click["date"] = date_key
        visitor_click["sold_clicks"] = sold_clicks
        visitor_click["duplicated_clicks"] = duplicated_clicks
        visitor_click["total_price"] = "%.2f" % sold_price
        @visitor_clicks << visitor_click
      end
    end

    @visitor_clicks_paging = @visitor_clicks.paginate(:page => params[:page] || 1, :per_page => 30)

    respond_to do |format|
      format.any(:html, :js) do
        @visitor_clicks_paging
      end
      format.xls do
        @visitor_clicks

        Axlsx::Package.new do |axlsx_package|
          axlsx_package.use_shared_strings = true
          start_time = Time.now
          axlsx_package.workbook do |wb|
            wb.styles do |style|
              wb.add_worksheet(name:'Report') do |sheet|

                en_titles = I18n.t('reports.clients_vertical_by_client_report.columns')
                title_bg_style = style.add_style :bg_color => "bbbbbb", 
                                                :border => { :style => :thin, :color => '000000' }

                sheet.add_row [
                  en_titles[:visitor_ip],
                  en_titles[:date],
                  en_titles[:sold_clicks], 
                  en_titles[:duplicated_clicks], 
                  en_titles[:total_price], 
                  en_titles[:date_from], 
                  en_titles[:date_to]
                ], :style => title_bg_style

                @visitor_clicks.each do |click|
                  sheet.add_row [
                    click["ip"],
                    click["date"],
                    click["sold_clicks"],
                    click["duplicated_clicks"],
                    click["total_price"],
                    params["from_date"],
                    params["to_date"]
                  ]
                end
              end
            end
          end

          send_data axlsx_package.to_stream.read, :filename => "ClicksReport_By_Client.xlsx"
        end
      end
    end
  end
end