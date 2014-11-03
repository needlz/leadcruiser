module Reporting
  class LeadStatistics

    def amount_per_day(first_date, last_date)
      period = period(first_date, last_date)
      day_format = "date_trunc('day', created_at)"
      graph_data = Lead.where(created_at: period).group(day_format).order(day_format).count

      result = []
      day = period.first
      while day < period.last
        graph_data.each do |date, leads_count|
          if date.strftime("%m/%d/%Y") == day.strftime("%m/%d/%Y")
            result << [day.beginning_of_day.to_i * 1000, leads_count]
          else
             result << [day.beginning_of_day.to_i * 1000, 0] unless graph_data.map { |a| a[0].strftime("%m/%d/%Y") }.include? day.strftime("%m/%d/%Y")
          end
        end
        day += 1.day
      end
      result
    end

    def leads(first_date, last_date, page=nil)
      leads = Lead.where(created_at: period(first_date, last_date))
      .joins(:details_pets)
      .order(created_at: :desc)
      leads = leads.paginate(page: page, per_page: 20) if page
      leads
    end

    private

    def period(first_date, last_date)
      from = first_date.nil? ? 14.days.ago : Time.parse(first_date).try(:beginning_of_day)
      to = last_date.nil? ? Time.now : Time.parse(last_date).try(:end_of_day)
      from..to
    end

  end
end

