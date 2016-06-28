class HealthInsuranceLeadValidation

  class Error < StandardError; end

  attr_reader :lead, :update_status

  def initialize(lead)
    @lead = lead
  end

  def validate(update_status = true)
    @update_status = update_status
    check_duplicated
    check_blocked
    check_disposition
  end

  def check_duplicated
    # If it is duplicated, it would not be sold
    duplicated = Lead.where(email: lead.email,
                            vertical_id: lead.vertical_id,
                            site_id: lead.site_id).count > 1

    if duplicated
      lead.update_attributes(status: Lead::DUPLICATED) if update_status
      raise Error.new('The email address of this lead was duplicated')
    end
  end

  def check_blocked
    # If the visitors are in block lists, it would be not be sold
    if PetInsuranceLeadValidation.blocked(lead)
      lead.update_attributes(status: Lead::BLOCKED, disposition: Lead::IP_BLOCKED) if update_status
      raise Error.new('Your IP address was blocked')
    end
  end

  def check_disposition
    # Testing disposition, Test No Sale
    if lead.first_name.downcase == Lead::TEST_TERM && lead.last_name.downcase == Lead::TEST_TERM
      lead.update_attributes(status: Lead::BLOCKED, disposition: Lead::TEST_NO_SALE) if update_status
      raise Error.new(Lead::TEST_NO_SALE)
    end
  end

  # Check the incoming lead with email was sold before
  def self.duplicated_lead(email, vertical_id, site_id)
    exist_lead = Lead.where(
      'email = ? and vertical_id = ? and site_id = ? and status = ?',
      email, vertical_id, site_id, Lead::SOLD).first

    exist_lead && exist_lead.responses.present?
  end

  # Check if incoming IP address is on block list
  def self.blocked(lead)
    BlockList.where('block_ip = ? and active = TRUE', lead.visitor_ip).exists?
  end

end
