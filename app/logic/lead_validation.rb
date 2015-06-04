class LeadValidation

  # Check the incoming lead with email was sold before
  def self.duplicated_lead(email, vertical_id, site_id)
    exist_lead = Lead.where(
      'email = ? and vertical_id = ? and site_id = ? and status = ?', 
      email, vertical_id, site_id, Lead::SOLD).first

    if exist_lead.nil? || exist_lead.responses.nil?
      false
    else
      true
    end
  end 

  # Check if incoming IP address is on block list
  def self.blocked(lead)
    if BlockList.where('block_ip = ? and active = TRUE', lead.visitor_ip).count > 0
      return true
    else
      return false
    end
  end

end