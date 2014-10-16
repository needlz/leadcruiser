class UserMailer

  include MandrillMailer

  def lead_creating(lead)
    template 'lead-was-created'
    set_template_values(set_lead_params(lead))
    mail to: wrap_recipient(ENV["RECIPIENT_EMAIL"], ENV["RECIPIENT_NAME"])
  end

  private

  def set_lead_params(lead)
    {
     first_name: lead.first_name,
     last_name: lead.last_name,
     zip: lead.zip,
     day_phone: lead.day_phone,
     email: lead.email
    }
  end

  def wrap_recipient(email, name)
    [{ email: email, name: name }]
  end
end