class HealthInsuranceMailer

  include SendGrid

  def thank_you(options)
    from = Email.new(email: 'test@leadcruiser-staging.herokuapp.com')
    subject = "Thanks for visiting #{ options[:site_name] }!"
    to = Email.new(email: options[:email])
    text = "Thanks so much for visiting #{ options[:site_name] }. We will be calling you soon to put you in touch with a licensed agent who can find the best plan for you."
    content = Content.new(type: 'text/plain', value: text)
    mail = Mail.new(from, subject, to, content)

    response = api.client.mail._('send').post(request_body: mail.to_json)
    pp response
    response
  end

  def notify_about_gethealthcare_threshold(recipients_emails)
    from = Email.new(email: 'test@leadcruiser-staging.herokuapp.com')
    subject = "Duration of gethealthcare.co form exceeded"
    to = Email.new(email: options[:email])
    text = renderer.renred_to_string('emails/gethealth_form_threshold_exceeded', locals: {  })
    content = Content.new(type: 'text/plain', value: text)
    mail = Mail.new(from, subject, to, content)

    response = api.client.mail._('send').post(request_body: mail.to_json)
    pp response
    response
  end

  private

  def api
    SendGrid::API.new(api_key: Settings.sendgrid_api_key)
  end

  def renderer
    ActionView::Base.new(ActionController::Base.view_paths, {})
  end

end