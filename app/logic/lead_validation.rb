class LeadValidation

  # Check the incoming lead with email was sold before
  def self.duplicated_lead(email, vertical_id, site_id)
    lead = find_sold_lead(email, vertical_id, site_id)

    lead.present? && lead.responses.present?
  end 

  # Check if incoming IP address is on block list
  def self.blocked(lead)
    BlockList.exists?(block_ip: lead.visitor_ip, active: true)
  end

  private

  def self.find_sold_lead(email, vertical_id, site_id)
    Lead.find_by(email: email,
                 vertical_id: vertical_id,
                 site_id: site_id,
                 status: Lead::SOLD)
  end
end
