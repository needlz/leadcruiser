# == Schema Information
#
# Table name: forwarding_time_ranges
#
#  id         :integer          not null, primary key
#  begin_day  :string           not null
#  begin_time :time             not null
#  end_day    :string           not null
#  end_time   :time             not null
#  kind       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ForwardingTimeRange < ActiveRecord::Base

  FORWARDING = 'forwarding'
  AFTERHOURS = 'afterhours'

  TIME_ZONE = -8
  ACTIVE_RECORD_TIME_ADAPTER_DEFAULT = Time.parse('2000-1-1')
  DEFAULT_YEAR = ACTIVE_RECORD_TIME_ADAPTER_DEFAULT.in_time_zone(TIME_ZONE)

  validates_inclusion_of :kind, in: [FORWARDING, AFTERHOURS]
  validates_inclusion_of :begin_day, :end_day, in: Date::DAYNAMES
  validates_presence_of :kind, :begin_day, :begin_time, :end_day, :end_time

  scope :forwarding, -> { where(kind: FORWARDING) }
  scope :afterhours, -> { where(kind: AFTERHOURS) }

  def self.inside_afterhours_range?
    range = closest_or_current_range(ForwardingTimeRange::AFTERHOURS)
    return unless range

    Time.current.between?(range[:start], range[:end])
  end

  def self.inside_forwarding_range?
    range = closest_or_current_forwarding_range
    return unless range

    Time.current.between?(range[:start], range[:end])
  end

  def self.any_forwarding_range?
    ForwardingTimeRange.forwarding.exists?
  end

  def self.closest_or_current_forwarding_range
    closest_or_current_range(ForwardingTimeRange::FORWARDING)
  end

  def self.closest_forwarding_range
    closest_range(ForwardingTimeRange::FORWARDING)
  end

  def self.closest_or_current_range(range_type)
    closest = nil
    each_range(range_type) do |specific_range|
      range_in_future = Time.current < specific_range[:start]
      inside_range = specific_range[:start] < Time.current && Time.current < specific_range[:end]
      closest = specific_range if (range_in_future || inside_range) && (!closest || (specific_range[:start] < closest[:start]))
    end
    closest
  end

  def self.closest_range(range_type)
    closest = nil
    each_range(range_type) do |specific_range|
      range_in_future = Time.current < specific_range[:start]
      closest = specific_range if (range_in_future) && (!closest || (specific_range[:start] < closest[:start]))
    end
    closest
  end

  def self.each_range(range_kind, &block)
    ForwardingTimeRange.send(range_kind).all.each do |range|
      week = Date.current.beginning_of_week.in_time_zone - 1.week

      single_range = range_of_week(range, week)

      block.call(single_range)
    end
    nil
  end

  def self.range_of_week(range, week)
    range_start = at_week(range.begin_day, range.begin_time.in_time_zone, week)
    range_end = at_week(range.end_day, range.end_time.in_time_zone, week)
    if range_start > range_end
      range_end = at_week(range.end_day, range.end_time.in_time_zone, week.next_week.in_time_zone)
    end
    range_end < Time.current ? range_of_week(range, week.next_week.in_time_zone) : { start: range_start, end: range_end }
  end

  def self.at_week(day, time, week)
    Time.zone.local(week.year,
               week.month,
               week.day,
               time.hour,
               time.min,
               time.sec).days_since(Date::DAYS_INTO_WEEK[day.downcase.to_sym]).in_time_zone
  end

  def self.mins_till_end_of_closest_forwarding_range
    range = closest_or_current_forwarding_range
    return unless range

    if inside_forwarding_range?
      ((range[:end].to_datetime - Time.current.to_datetime) * 24 * 60).to_i
    else
      ((range[:end].to_datetime - range[:start].to_datetime) * 24 * 60).to_i
    end
  end


end
