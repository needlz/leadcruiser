class PetfirstResponseMailer

  include MandrillMailer

  def send_email(lead_id)
    lead = Lead.find_by_id(lead_id)
    template 'petfirst-response'
    subject = "Lead request from pet-insurance.org"
    set_template_values(set_lead_params(lead))
    mail to: [wrap_recipient(ENV["PETFIRST_EMAIL"], ENV["PETFIRST_NAME"], "to")], subject:subject
    # mail to: [wrap_recipient(ENV["RECIPIENT_SELF_EMAIL"], ENV["RECIPIENT_SELF_NAME"], "to")], subject:subject

  end

  private

  def set_lead_params(lead)
    {
      owner_name: lead.first_name,
      first_name: lead.first_name,
      last_name: lead.last_name,
      email: lead.email,
      day_phone: lead.day_phone,
      zip: lead.zip,
      visitor_ip: lead.visitor_ip,
      pet_name: lead.details_pets.first.pet_name,
      species: lead.details_pets.first.species,
      breed: lead.details_pets.first.breed,
      spayed_or_neutered:  lead.details_pets.first.spayed_or_neutered ? 'Yes' : 'No',
      birth_month: Date::MONTHNAMES[lead.details_pets.first.birth_month],
      birth_year: lead.details_pets.first.birth_year,
      gender: lead.details_pets.first.gender,
      conditions: lead.details_pets.first.conditions ? 'Yes' : 'No'
    }
  end

  def wrap_recipient(email, name, type)
    { email: email, name: name, type: type }
  end

  private

  def env_field
    '(' + ENV['RAILS_ENV'] + ')' unless ENV['RAILS_ENV'] == 'production'
  end
end