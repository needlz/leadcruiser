module Reporting
  class LeadStatistics

    def amount_per_day(first_date, second_date)
      begin_date = Time.at(first_date.to_i)
      finish_date = Time.at(second_date.to_i)
      day_format = "date_trunc('day', created_at)"

      graph_data = Lead.where(created_at: begin_date..finish_date).group(day_format).order(day_format).count

      result = []
      time_period = begin_date.to_date.beginning_of_day.to_time.to_i..finish_date.to_date.beginning_of_day.to_time.to_i

      time_period.step(1.day).each do |day|
        graph_data.each do |date, leads_count|
          if date.beginning_of_day.to_i == day
            result << [day * 1000, leads_count]
          else
            result << [day * 1000, 0] unless graph_data.map { |a| a[0].to_i }.include? day
          end
        end
      end
      result
    end

  end
end

