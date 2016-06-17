module ErrorMessages

  extend ActiveSupport::Concern

  def error_messages
    errors.values.flatten
  end

end