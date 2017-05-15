class PurchaseOrderTimeFilter
  attr_reader :purchase_order, :datetime

  def initialize(purchase_order, datetime)
    @purchase_order = purchase_order
    @datetime = datetime
  end

  def allow?
    Date::DAYNAMES.each do |day_name|
      day = day_name.downcase
      begin_time = purchase_order.send("#{ day }_begin_time")
      end_time = purchase_order.send("#{ day }_end_time")
      if apply_filter?(day, begin_time, end_time)
        return in_range?(begin_time, end_time)
      end
    end
    true
  end

  def apply_filter?(day, begin_time, end_time)
    filter_enabled = purchase_order.send("#{ day }_filter_enabled")
    filter_enabled && begin_time.present? && end_time.present? && datetime.strftime("%A").downcase == day
  end

  def in_range?(begin_time, end_time)
    begin_datetime = today_time(begin_time.in_time_zone)
    end_datetime = today_time(end_time.in_time_zone)
    datetime.between?(begin_datetime, end_datetime)
  end

  def today_time(time)
    Time.zone.local(datetime.year,
                    datetime.month,
                    datetime.day,
                    time.hour,
                    time.min,
                    time.sec).in_time_zone
  end

end
