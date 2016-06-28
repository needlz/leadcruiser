class EditableConfiguration < ActiveRecord::Base

  def self.global
    first
  end
end
