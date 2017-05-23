module Reporting

  class LeadRow

    attr_reader :lead
    attr_accessor :price, :sold_type, :clients

    def initialize(lead)
      @lead = lead
    end

    def to_array
      [
        lead.id,
        lead.vertical.name,
        lead.site.host,
        lead.visitor_ip,
        lead.first_name,
        lead.last_name,
        lead.zip,
        lead.state,
        lead.email,
        ((lead.details_pets.first.conditions? ? 'TRUE' : 'FALSE') if lead.pet_insurance?),
        lead.times_sold.nil? ? 0 : lead.times_sold,
        price,
        clients,
        sold_type,
        lead.created_at,
        "tel:" + lead.day_phone,
        lead.details_pets.first.try(:pet_name),
        lead.details_pets.first.try(:species),
        lead.details_pets.first.try(:breed),
        ((lead.details_pets.first.spayed_or_neutered? ? 'TRUE' : 'FALSE') if lead.pet_insurance?),
        lead.details_pets.first.try(:birth_month),
        lead.details_pets.first.try(:birth_year),
        lead.details_pets.first.try(:gender),
        lead.visitor.nil? ? '' : lead.visitor.session_hash,
        lead.visitor.nil? ? '' : lead.visitor.referring_url,
        lead.visitor.nil? ? '' : lead.visitor.landing_page,
        lead.visitor.nil? ? '' : lead.visitor.keywords,
        lead.health_insurance_lead.try(:ref)
      ]
    end
  end
end
