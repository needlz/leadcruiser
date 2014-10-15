module ErrorMessages

  extend ActiveSupport::Concern

  def error_messages
    errors.messages.values.flatten
  end

end