module ErrorMessages

  extend ActiveSupport::Concern

  def error_messages
    errors.full_messages
  end

end