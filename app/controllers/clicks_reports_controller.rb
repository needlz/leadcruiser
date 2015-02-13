class ClicksReportsController < ApplicationController

  http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

  def index
    clients_verticals = ClientsVertical.where('active = true').order(:vertical_id)

    @clients_verticals_clicks = []
    clients_verticals.each do |cv|
      clicks = Click.where('clients_vertical_id = ?', cv.id)
      
      total_info = {}
      total_clicks = 0
      sold_clicks = 0
      total_price =0
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
  end

  def by_client
    @clients_vertical = ClientsVertical.find params["clients_vertical_id"]
    visitor_ip_list = Click.where('clients_vertical_id = ?', params["clients_vertical_id"])
                            .group('visitor_ip')
                            .order('visitor_ip')
                            .select("visitor_ip")

    @visitor_clicks = []
    visitor_ip_list.each do |visitor|
      click_list = Click.where('clients_vertical_id = ? and visitor_ip = ?', params["clients_vertical_id"], visitor.visitor_ip)
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
  end
end