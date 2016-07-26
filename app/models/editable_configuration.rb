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
    return if !afterhours_range_start || !afterhours_range_end
    Time.current.between?(today_afterhours_range_start, today_afterhours_range_end)
  end

  def inside_forwarding_range?
    Time.current.between?(today_forwarding_range_start, today_forwarding_range_end)
  end

  def forwarding_range?
    forwarding_range_start && forwarding_range_end && (forwarding_range_start < forwarding_range_end)
  end

  def today_range_start(time)
    at_day(time)
  end

  def today_afterhours_range_start
    today_range_start(afterhours_range_start)
  end

  def today_afterhours_range_end
    today_range_end(afterhours_range_start, afterhours_range_end)
  end

  def today_forwarding_range_start
    today_range_start(forwarding_range_start)
  end

  def today_forwarding_range_end
    today_range_end(forwarding_range_start, forwarding_range_end)
  end

  def today_range_end(start_time, time)
    today_end = at_day(time)
    today_end < start_time ? at_day(time, Date.current.tomorrow) : today_end
  end

  def at_day(time, day = Date.current)
    DateTime.new(day.year,
                 day.month,
                 day.day,
                 time.hour,
                 time.min,
                 time.sec)
  end

  def forwarding_range_length_mins
    ((today_forwarding_range_end - today_forwarding_range_start) * 24 * 60).to_i
  end

end
