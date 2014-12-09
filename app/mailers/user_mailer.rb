class UserMailer

  include MandrillMailer

  def lead_creating(response)
    lead = response.lead
    template 'lead-was-created'
    subject = "Pet-Insurance.org #{env_field} New Lead - ID: #{lead.id} - #{lead.created_at}"
    set_template_values(set_lead_params(lead, response))

    mail to: [wrap_recipient(ENV["RECIPIENT_EMAIL"], ENV["RECIPIENT_NAME"], "to"),
              wrap_recipient(ENV["RECIPIENT_BCC_EMAIL"], ENV["RECIPIENT_BCC_NAME"], "bcc")], subject:subject
  end

  private

  def set_lead_params(lead, response)
    client = ClientsVertical.where('integration_name = ?', response.client_name).first
    {
     first_name: lead.first_name,
     last_name: lead.last_name,
     email: lead.email,
     day_phone: lead.day_phone,
     zip: lead.zip,
     state: lead.state || lead.try(:zip_code).try(:state),
     visitor_ip: lead.visitor_ip,
     pet_name: lead.details_pets.first.pet_name,
     species: lead.details_pets.first.species,
     breed: lead.details_pets.first.breed,
     spayed_or_neutered:  lead.details_pets.first.spayed_or_neutered.to_s,
     birth_month: Date::MONTHNAMES[lead.details_pets.first.birth_month],
     birth_year: lead.details_pets.first.birth_year,
     gender: lead.details_pets.first.gender,
     conditions: lead.details_pets.first.conditions.to_s,
     client_name: client.official_name,
     session_hash: lead.try(:visitor).try(:session_hash),
     referring_url: lead.try(:visitor).try(:referring_url),
     landing_page: lead.try(:visitor).try(:landing_page),
     keywords: lead.try(:visitor).try(:keywords),
     utm_medium: lead.try(:visitor).try(:utm_medium),
     utm_source: lead.try(:visitor).try(:utm_source),
     utm_campaign: lead.try(:visitor).try(:utm_campaign),
     utm_term: lead.try(:visitor).try(:utm_term),
     utm_content: lead.try(:visitor).try(:utm_content),
     location: lead.try(:visitor).try(:location)
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