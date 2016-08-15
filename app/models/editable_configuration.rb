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

  validates_numericality_of :forwarding_interval_minutes, greater_than: 0

  def self.global
    first
  end

end
