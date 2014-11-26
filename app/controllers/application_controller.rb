class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session
	protect_from_forgery with: :exception

  # Check the incoming lead with email was sold before
  def duplicated_lead(email, vertical_id)
    
    exist_lead = Lead.where('email = ? and vertical_id = ? and status = ?', email, vertical_id, Lead::SOLD).first
    if exist_lead.nil? || exist_lead.response.nil? || exist_lead.response.client_name == ''
      return false
    else
      return true
    end

    return false
  end	
end
