class PetsBestGenerator

  LINK = ""

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def generate
    promocode = "PIOEL"

    query = {
      :ci => promocode,
      :ofn => lead.first_name,
      :oln => lead.last_name,
      :oas => lead.address_1.nil? ? "" : lead.address_1,
      :oac => lead.city || lead.try(:zip_code).try(:primary_city) || '',
      :oaz => lead.zip,
      :oph => lead.day_phone,
      :oea => lead.email,
      :aqr => true,
      :Json => true
    }

    query = generate_pet_query query
    
    return query
  end

  def generate_pet_query (query)
    idx = 1;
    lead.details_pets.each do |pet|
      idx_str = idx.to_s
      query["pn"+idx_str]   = pet.pet_name
      query["s"+idx_str]    = pet.species
      query["b"+idx_str]    = pet.breed_to_send('pets_best')
      query["g"+idx_str]    = pet.gender.downcase
      query["dob"+idx_str]  = pet.birth_month.to_s + "-" + pet.birth_day.to_s + "-" + pet.birth_year.to_s
      query["mc"+idx_str]   = pet.conditions

      idx = idx + 1
    end

    return query
  end

end