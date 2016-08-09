class HealthInsuranceMailer

  include SendGrid

  SENDGRID_TEMPLATE_IDS =
    if Rails.env.production?
      {
        RequestToBoberdoo::HEALTH_INSURANCE_TYPE => {
          'healthmatchup.com' => '14c4b97a-5685-4780-9232-4bb7b567a7e4',
          'gethealthcare.co' => '6d52562d-2b4d-4790-99e5-fc99118b5bb1'
        },
        RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE => {
          'healthmatchup.com' => 'f6e0c20f-9c17-4c2a-a450-38ea32064591',
          'gethealthcare.co' => 'e2338983-4c54-4ab4-8ba1-6817ede29cf1'
        },
      }
    else
      {
        RequestToBoberdoo::HEALTH_INSURANCE_TYPE => {
          'healthmatchup.com' => 'e9ce4afd-92dc-4d77-b153-0cc5812dec1f',
          'gethealthcare.co' => '5055f760-8d8b-4088-85e6-394bc121c83c'
        },
        RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE => {
          'healthmatchup.com' => '7a776324-4309-4af9-918d-94aba4d95a68',
          'gethealthcare.co' => '922ded5c-a957-42c8-b9e9-ec880b31717a'
        },
      }
    end

  PERSONALIZED_URL = {
    RequestToBoberdoo::HEALTH_INSURANCE_TYPE => {
      'healthmatchup.com' => 'http://healthmatchup.com/results/?zip=%{zip}',
      'gethealthcare.co' => 'http://gethealthcare.co/results/?zip=%{zip}'
    },
    RequestToBoberdoo::MEDICARE_SUPPLEMENT_INSURANCE_TYPE => {
      'healthmatchup.com' => 'http://healthmatchup.com/results/?zip=%{zip}&medicare=yes',
      'gethealthcare.co' => 'http://gethealthcare.co/results/?zip=%{zip}&medicare=yes'
    },
  }

  FROM_ADDRESSES = {
    'healthmatchup.com' => 'justin@healthmatchup.com',
    'gethealthcare.co' => 'justin@gethealthcare.co'
  }

  AUTORESPONDER_FROM_NAME = 'Justin'

  def thank_you(lead_id)
    lead = Lead.find(lead_id)
    mail = prepare_email do |personalization|
      personalization.to = Email.new(email: lead.email, name: lead.name)
      personalization.substitutions = Substitution.new(key: '&lt;%FirstName%&gt;', value: lead.first_name)
      personalization.substitutions = Substitution.new(key: '&lt;%PersonalizedQuotesUrl%&gt;', value: personalized_quotes_url(lead))
    end
    mail.from = Email.new(email: from_address(lead), name: AUTORESPONDER_FROM_NAME)
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
    mail.from = Email.new(email: "#{ Rails.env }@leadcruiser.com")
    mail.template_id = sendgrid_template_id(:notify_about_gethealthcare_threshold)
    send_mail(mail)
  end

  def notify_about_gethealthcare_errors
    mail = prepare_email do |personalization|
      owners.each { |owner_email| personalization.to = Email.new(email: owner_email) }
    end
    mail.from = Email.new(email: "#{ Rails.env }@leadcruiser.com")
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
    mail.contents = Content.new(type: 'text/html', value: '?')
    personalization = Personalization.new
    personalization_block.call(personalization)
    mail.personalizations = personalization
    mail
  end

  def send_mail(mail)
    api.client.mail._('send').post(request_body: mail.to_json)
  end

  def from_address(lead)
    FROM_ADDRESSES[lead.site.domain]
  end

  def api
    SendGrid::API.new(api_key: Settings.sendgrid_api_key)
  end

  def renderer
    ActionView::Base.new(ActionController::Base.view_paths, {})
  end

  def owners
    return [] unless EditableConfiguration.global.gethealthcare_notified_recipients_comma_separated.present?
    EditableConfiguration.global.gethealthcare_notified_recipients_comma_separated.split(/,\s*/)
  end

  def personalized_quotes_url(lead)
    url_template = PERSONALIZED_URL[lead.health_insurance_lead.boberdoo_type][lead.site.domain]
    url_template % { zip: lead.zip }
  end
end
