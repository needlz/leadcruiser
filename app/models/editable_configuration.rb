# == Schema Information
#
# Table name: editable_configurations
#
#  id                                                :integer          not null, primary key
#  gethealthcare_form_monitor_delay_minutes          :integer          default(30)
#  gethealthcare_form_threshold_seconds              :integer          default(20)
#  gethealthcare_notified_recipients_comma_separated :text
#

class EditableConfiguration < ActiveRecord::Base

  def self.global
    first
  end
end
