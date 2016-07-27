class Ranges

  def self.fullname_attributes
    res = []
    days.each do |day|
      attributes.each do |attr|
        res << attr_name(day, attr)
      end
    end
    res
  end

  def self.days
    Date::ABBR_DAYNAMES.map(&:downcase)
  end

  def self.attributes
    [:afterhours_range_start, :afterhours_range_end, :forwarding_range_start, :forwarding_range_end]
  end

  def self.attr_name(day, attr)
    "#{ day }_#{ attr }"
  end

end
