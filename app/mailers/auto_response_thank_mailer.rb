class AutoResponseThankMailer

  include MandrillMailer

  def send_email(email_address)
    template 'auto-response-user'
    subject = "Thanks for visiting Pet-Insurance.org!"
    set_template_values(set_lead_params)

    mail to: [wrap_recipient(email_address, "", "to")], subject:subject
  end

  private

  def set_lead_params()
    {}
  end

  def wrap_recipient(email, name, type)
    { email: email, name: name, type: type }
  end

end