class HealthInsuranceMailer

  include SendGrid

  SENDGRID_TEMPLATE_IDS = {
    thank_you: '56a6f854-8c13-425e-8835-e88ec9d476a7',
    notify_about_gethealthcare_threshold: 'da47c791-c268-4ab6-a03d-6dbe98732a79',
    notify_about_gethealthcare_errors: 'a787181a-b883-48b5-9fda-dc335d8349b1'
  }

  def thank_you(options)
    mail = prepare_email do |personalization|
      personalization.to = Email.new(email: options[:email], name: options[:name])
      personalization.substitutions = Substitution.new(key: '-site_name-', value: options[:site_name])
    end
    mail.template_id = sendgrid_template_id(:thank_you)
    send_mail(mail)
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

  def sendgrid_template_id(template)
    SENDGRID_TEMPLATE_IDS[template]
  end

  def prepare_email(&personalization_block)
    mail = Mail.new
    mail.from = Email.new(email: from_address)
    mail.contents = Content.new(type: 'text/plain', value: '?')
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
