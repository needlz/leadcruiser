class UserMailer

  include MandrillMailer

  def lead_creating(response_id_list, lead_id)
    lead = Lead.find(lead_id)
    unless lead.nil?
      template 'lead-was-sold'
      subject = "Pet-Insurance.org #{env_field} New Lead - ID: #{lead.id} - #{lead.created_at}"
      set_template_values(set_lead_params(response_id_list, lead))

      mail to: [wrap_recipient(ENV["RECIPIENT_EMAIL"], ENV["RECIPIENT_NAME"], "to"),
                wrap_recipient(ENV["RECIPIENT_BCC_EMAIL"], ENV["RECIPIENT_BCC_NAME"], "bcc")], subject:subject
    end
  end

  private

  def set_lead_params(response_id_list, lead)
    
    body = {
      first_name:         lead.first_name,
      last_name:          lead.last_name,
      email:              lead.email,
      day_phone:          lead.day_phone,
      zip:                lead.zip,
      state:              lead.state || lead.try(:zip_code).try(:state),
      visitor_ip:         lead.visitor_ip,
      disposition:        lead.disposition,
      pet_name:           lead.details_pets.first.pet_name,
      species:            lead.details_pets.first.species,
      breed:              lead.details_pets.first.breed,
      spayed_or_neutered: lead.details_pets.first.spayed_or_neutered.to_s,
      birth_month:        Date::MONTHNAMES[lead.details_pets.first.birth_month],
      birth_year:         lead.details_pets.first.birth_year,
      gender:             lead.details_pets.first.gender,
      conditions:         lead.details_pets.first.conditions.to_s,
      session_hash:       lead.try(:visitor).try(:session_hash),
      referring_url:      lead.try(:visitor).try(:referring_url),
      landing_page:       lead.try(:visitor).try(:landing_page),
      keywords:           lead.try(:visitor).try(:keywords),
      utm_medium:         lead.try(:visitor).try(:utm_medium),
      utm_source:         lead.try(:visitor).try(:utm_source),
      utm_campaign:       lead.try(:visitor).try(:utm_campaign),
      utm_term:           lead.try(:visitor).try(:utm_term),
      utm_content:        lead.try(:visitor).try(:utm_content),
      location:           lead.try(:visitor).try(:location)  
    }

    total_revenue = 0
    unless response_id_list.nil?
      for i in 0..9
        if response_id_list[i].nil?
          body[("client_name"+(i+1).to_s).to_sym] = nil
          body[("sold_price"+(i+1).to_s).to_sym] = nil
        else
          response = Response.find(response_id_list[i])
          client = ClientsVertical.find_by_integration_name(response.try(:client_name))

          weight = response.purchase_order.weight
          if weight.nil?
            weight = 0
          end

          body[("client_name"+(i+1).to_s).to_sym] = client.official_name
          body[("sold_price"+(i+1).to_s).to_sym] = (response.price - weight).to_s

          total_revenue += response.price
        end
      end
    end
    body[:total_revenue] = total_revenue.to_s
    
    return body
  end

  def wrap_recipient(email, name, type)
    { email: email, name: name, type: type }
  end

  private

  def env_field
    '(' + ENV['RAILS_ENV'] + ')' unless ENV['RAILS_ENV'] == 'production'
  end
end