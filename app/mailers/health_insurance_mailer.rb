class HealthInsuranceMailer

  include SendGrid

  SENDGRID_TEMPLATE_IDS = {
    RequestToBoberdoo::HEALTH_INSURANCE_TYPE => {
      'healthmatchup.com' => '14c4b97a-5685-4780-9232-4bb7b567a7e4',
      'gethealthcare.co' => '6d52562d-2b4d-4790-99e5-fc99118b5bb1'
    },
    RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE => {
      'healthmatchup.com' => 'f6e0c20f-9c17-4c2a-a450-38ea32064591',
      'gethealthcare.co' => 'e2338983-4c54-4ab4-8ba1-6817ede29cf1'
    },
  }

  def thank_you(lead_id)
    lead = Lead.find(lead_id)
    mail = prepare_email do |personalization|
      personalization.to = Email.new(email: lead.email, name: lead.name)
      personalization.substitutions = Substitution.new(key: '&lt;%FirstName%&gt;', value: lead.first_name)
    end
    mail.template_id = autoresponder_template_id(lead)
    send_mail(mail)
  end

  def autoresponder_template_id(lead)
    SENDGRID_TEMPLATE_IDS[lead.health_insurance_lead.boberdoo_type][lead.site.domain]
  end

  def notify_about_gethealthcare_threshold
    mail = prepare_email do |personalization|
      owners.each { |owner_email| personalization.to = Email.new(email: owner_email) }
    end
    mail.template_id = sendgrid_template_id(:notify_about_gethealthcare_threshold)
    send_mail(mail)
  end

  def notify_about_gethealthcare_errors
    mail = prepare_email do |personalization|
      owners.each { |owner_email| personalization.to = Email.new(email: owner_email) }
    end
    mail.template_id = sendgrid_template_id(:notify_about_gethealthcare_errors)
    send_mail(mail)
  end

  private

  def sendgrid_template_id(template_symbol)
    {
      notify_about_gethealthcare_threshold: 'da47c791-c268-4ab6-a03d-6dbe98732a79',
      notify_about_gethealthcare_errors: 'a787181a-b883-48b5-9fda-dc335d8349b1'
    }[template_symbol]
  end

  def prepare_email(&personalization_block)
    mail = Mail.new
    mail.from = Email.new(email: from_address)
    mail.contents = Content.new(type: 'text/html', value: '?')
    personalization = Personalization.new
    personalization_block.call(personalization)
    mail.personalizations = personalization
    mail
  end

  def send_mail(mail)
    api.client.mail._('send').post(request_body: mail.to_json)
  end

  def from_address
    "#{ Rails.env }@leadcruiser.com"
  end

  def api
    SendGrid::API.new(api_key: Settings.sendgrid_api_key)
  end

  def renderer
    ActionView::Base.new(ActionController::Base.view_paths, {})
  end

  def owners
    EditableConfiguration.global.gethealthcare_notified_recipients_comma_separated.split(/,\s*/)
  end
end
