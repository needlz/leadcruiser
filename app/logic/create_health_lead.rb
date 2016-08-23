class CreateHealthLead

  attr_reader :form, :lead, :errors

  def initialize(form)
    @form = form
  end

  def perform
    saved = false
    ActiveRecord::Base.transaction do
      @lead = Lead.new(form.lead_attributes)
      saved = lead.save
    end
    ActiveRecord::Base.transaction do
      if saved
        process_lead_created_by_crawler(lead)
        run_validations

        HealthInsuranceLead.create!(form.health_insurance_lead_attributes.merge({ lead_id: lead.id }))

        if lead_valid?(lead)
          ForwardHealthInsuranceLead.perform(lead)
          AddSendgridContactJob.perform_later(lead.id)
        end
      else
        @errors = lead.error_messages
      end
    end
  end

  def run_validations
    begin
      HealthInsuranceLeadValidation.new(lead).validate
    rescue HealthInsuranceLeadValidation::Error => validation_error
      @errors = validation_error.message
    end
  end

  def process_lead_created_by_crawler(lead)
    if lead.test?
      hit_id = get_id_from_phone_number(lead.day_phone)
      hit = GethealthcareHit.find_by_id(hit_id)
      return unless hit
      hit.lead = lead
      hit.save!
    end
  end

  def get_id_from_phone_number phone_number
    number_without_code = phone_number.to_s[3..-1]
    number_without_code.to_i
  end

  def lead_valid?(lead)
    lead.status.nil?
  end

end
