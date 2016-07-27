# == Schema Information
#
# Table name: editable_configurations
#
#  id                                                :integer          not null, primary key
#  gethealthcare_form_monitor_delay_minutes          :integer          default(30)
#  gethealthcare_form_threshold_seconds              :integer          default(20)
#  gethealthcare_notified_recipients_comma_separated :text
#  afterhours_range_start                            :time
#  afterhours_range_end                              :time
#  forwarding_range_start                            :time
#  forwarding_range_end                              :time
#  forwarding_interval_minutes                       :integer          default(5)
#

class EditableConfiguration < ActiveRecord::Base

  def self.global
    first
  end

  def inside_afterhours_range?
    range = closest_or_current_range('afterhours')
    return unless range

    Time.current.between?(range[:start], range[:end])
  end

  def inside_forwarding_range?
    range = closest_or_current_forwarding_range
    return unless range

    Time.current.between?(range[:start], range[:end])
  end

  def any_forwarding_range?
    Ranges.days.each do |day|
      range_start = send("#{ day }_forwarding_range_start")
      range_end = send("#{ day }_forwarding_range_end")
      return true if range_start && range_end
    end
    false
  end

  def closest_or_current_forwarding_range
    closest_or_current_range('forwarding')
  end

  def closest_forwarding_range
    closest_range('forwarding')
  end

  def closest_or_current_range(range_type)
    each_range(range_type) do |range_start, range_end|
      range_in_future = Time.current < range_start
      inside_range = range_start < Time.current && Time.current < range_end
      break { start: range_start, end: range_end } if range_in_future || inside_range
    end
  end

  def closest_range(range_type)
    each_range(range_type) do |range_start, range_end|
      range_in_future = Time.current < range_start
      break { start: range_start, end: range_end } if range_in_future
    end
  end

  def each_range(range_type, &block)
    Ranges.days.rotate(Time.current.wday).each_with_index do |day, day_offset|
      start_time = send Ranges.attr_name(day, "#{ range_type }_range_start")
      end_time = send Ranges.attr_name(day, "#{ range_type }_range_end")
      date = Date.current.days_since(day_offset)

      next if start_time.nil? || end_time.nil?

      range_start = range_start_of_day(start_time, date)
      range_end = range_end_of_day(start_time, end_time, date)

      block.call(range_start, range_end)
    end
    nil
  end

  def range_start_of_day(time, date)
    at_day(time, date)
  end

  def range_end_of_day(start_time, time, date)
    today_end = at_day(time, date)
    today_end < start_time ? at_day(time, date.tomorrow) : today_end
  end

  def at_day(time, day = Date.current)
    DateTime.new(day.year,
                 day.month,
                 day.day,
                 time.hour,
                 time.min,
                 time.sec)
  end

  def closest_forwarding_range_length_mins
    range = closest_or_current_forwarding_range
    return unless range

    if inside_forwarding_range?
      (range[:end].to_i - Time.current.to_i) * 24 * 60
    else
      (range[:end].to_i - range[:start].to_i) * 24 * 60
    end
  end

end
