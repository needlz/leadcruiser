class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session

  def respond_with_error(message, status = 500)
    render json: { error: message }, status: status
  end

end
