class FormatTime

  def self.for(time)
    time.strftime('%H:%M %Z') if time
  end

end
