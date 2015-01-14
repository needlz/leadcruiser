class HealthyPawsGenerator

  LINK = ""

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def generate(exclusive)
    partner_source = "PRESIDIO"

    query = {}
    query["1"]  = lead.first_name
    query["2"]  = lead.first_name
    query["3"]  = lead.address_1.nil? ? "" : lead.address_1
    query["4"]  = lead.city || lead.try(:zip_code).try(:primary_city) || ''
    query["5"]  = lead.state || lead.try(:zip_code).try(:state) || ''
    query["6"]  = lead.zip
    query["7"]  = lead.day_phone
    query["8"]  = lead.email
    query["31"] = partner_source

    if exclusive?
      query["32"] = "Exclusive"     
    else
      query["32"] = "Shared"
    end

    query = generate_pet_query query
  end

  def generate_pet_query (query)
    pet = lead.details_pets.try(:first)
    query["9"]  = pet.species.downcase
    query["10"] = pet.breed_to_send('healthy_paws')
    query["11"] = pet.birth_month.to_s + "/" + pet.birth_year.to_s
    query["22"] = pet.gender[0, 1]
    query["23"] = pet.pet_name
    query["28"] = pet.spayed_or_neutered ? "Y" : "N"
    
    return query
  end

end