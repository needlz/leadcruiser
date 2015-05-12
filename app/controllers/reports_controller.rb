require 'axlsx'

class ReportsController < ApplicationController
  include ApplicationHelper

  http_basic_authenticate_with name: LOGIN_NAME, password: LOGIN_PASSWORD

  def index
    respond_to do |format|
      format.any(:html, :js) do
        @leads_per_day = statistic.amount_per_day(params[:firstDate], params[:secondDate])
        @leads = statistic.leads(params[:firstDate], params[:secondDate], params[:page] || 1)
      end
      format.xls do
        leads = statistic.leads(params[:firstDate], params[:secondDate])
        Axlsx::Package.new do |axlsx_package|
          axlsx_package.use_shared_strings = true
          start_time = Time.now
          axlsx_package.workbook do |wb|
            wb.styles do |style|
              wb.add_worksheet(name:'Report') do |sheet|

                en_titles = I18n.t('reports.lead.columns')
                title_bg_style = style.add_style :bg_color => "bbbbbb", 
                                                :border => { :style => :thin, :color => '000000' }

                sheet.add_row [
                  en_titles[:lead_id], 
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

                leads.each do |lead|
                  if lead.sold_responses.length == 0
                    sheet.add_row [
                      lead.id,
                      lead.visitor_ip,
                      lead.first_name,
                      lead.last_name,
                      lead.zip,
                      lead.state,
                      lead.email,
                      lead.details_pets.first.conditions? ? 'TRUE' : 'FALSE',
                      lead.times_sold.nil? ? 0 : lead.times_sold,
                      '$0.00',
                      '',
                      '',
                      UTCToPST(lead.created_at),
                      "tel:" + lead.day_phone,
                      lead.details_pets.first.pet_name,
                      lead.details_pets.first.species,
                      lead.details_pets.first.breed,
                      lead.details_pets.first.spayed_or_neutered? ? 'TRUE' : 'FALSE',
                      lead.details_pets.first.birth_month,
                      lead.details_pets.first.birth_year,
                      lead.details_pets.first.gender,
                      lead.visitor.nil? ? '' : lead.visitor.session_hash,
                      lead.visitor.nil? ? '' : lead.visitor.referring_url,
                      lead.visitor.nil? ? '' : lead.visitor.landing_page,
                      lead.visitor.nil? ? '' : lead.visitor.keywords
                    ]
                  else
                    lead.sold_responses.each do |response|
                      sheet.add_row [
                        lead.id,
                        lead.visitor_ip,
                        lead.first_name,
                        lead.last_name,
                        lead.zip,
                        lead.state,
                        lead.email,
                        lead.details_pets.first.conditions? ? 'TRUE' : 'FALSE',
                        lead.times_sold.nil? ? 0 : lead.times_sold,
                        '$' + lead.sold_po_price(response.purchase_order_id).to_s,
                        lead.client_sold_to(response.client_name).try(:official_name),
                        lead.sold_type.nil? ? 'Exclusive' : lead.sold_type.exclusive_selling? ? 'Exclusive' : 'Shared',
                        UTCToPST(lead.created_at),
                        "tel:" + lead.day_phone,
                        lead.details_pets.first.pet_name,
                        lead.details_pets.first.species,
                        lead.details_pets.first.breed,
                        lead.details_pets.first.spayed_or_neutered? ? 'TRUE' : 'FALSE',
                        lead.details_pets.first.birth_month,
                        lead.details_pets.first.birth_year,
                        lead.details_pets.first.gender,
                        lead.visitor.nil? ? '' : lead.visitor.session_hash,
                        lead.visitor.nil? ? '' : lead.visitor.referring_url,
                        lead.visitor.nil? ? '' : lead.visitor.landing_page,
                        lead.visitor.nil? ? '' : lead.visitor.keywords
                      ]
                    end
                  end
                end
              end
            end
          end
          end_time = Time.now
          diff = end_time - start_time
          puts "------------------- Generating Reports ------------------" + diff.to_s

          send_data axlsx_package.to_stream.read, :filename => "Report.xlsx"
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