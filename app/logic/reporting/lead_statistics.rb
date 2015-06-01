module Reporting
  class LeadStatistics

    def amount_per_day(first_date, last_date)
      period = period(first_date, last_date)

      day_format = "date_trunc('day', created_at)"
      amount_per_existing_days = Lead.where(created_at: period).group(day_format).order(day_format).count

      result = []
      day = period.first
      while day < period.last
        matching_item = amount_per_existing_days.detect{ |item| item[0].to_date == day.to_date }
        result << [day.beginning_of_day.to_i * 1000, matching_item ? matching_item[1] : 0]
        day += 1.day
      end
      result
    end

    def leads(first_date, last_date, page=nil)
      leads = Lead.where(created_at: period(first_date, last_date))
        .joins(:details_pets)
        .order(created_at: :desc)
        .includes(:details_pets, :visitor)
      return leads unless page
      leads.paginate(page: page, per_page: 20)
    end

    private

    def period(first_date, last_date)
      Time.zone = "Pacific Time (US & Canada)"
      from = first_date.nil? || first_date == "" ? 14.days.ago : Time.zone.parse(first_date).try(:beginning_of_day)
      to = last_date.nil? || last_date == "" ? Time.zone.now : Time.zone.parse(last_date).try(:end_of_day)

      from = from.in_time_zone("UTC")
      to = to.in_time_zone("UTC")
      # from = first_date.nil? || first_date == "" ? 14.days.ago : Time.parse(first_date).try(:beginning_of_day)
      # to = last_date.nil? || last_date == "" ? Time.now : Time.parse(last_date).try(:end_of_day)
      from..to
    end

  end
end

