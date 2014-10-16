class UserMailer

  include MandrillMailer

  def lead_creating(lead)
    template 'lead-was-created'
    subject = "Pet-Insurance.org New Lead - #{lead.id} #{lead.created_at} "
    set_template_values(set_lead_params(lead))

    mail to: [wrap_recipient(ENV["RECIPIENT_EMAIL"], ENV["RECIPIENT_NAME"], "to"),
              wrap_recipient(ENV["RECIPIENT_BCC_EMAIL"], ENV["RECIPIENT_BCC_NAME"], "bcc")], subject:subject

  end

  private

  def set_lead_params(lead)
    {
     first_name: lead.first_name,
     last_name: lead.last_name,
     email: lead.email,
     day_phone: lead.day_phone,
     zip: lead.zip,
     pet_name: lead.details_pets.first.pet_name,
     species: lead.details_pets.first.species,
     breed: lead.details_pets.first.breed
    }
  end

  def wrap_recipient(email, name, type)
    { email: email, name: name, type: type }
  end
end