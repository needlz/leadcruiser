class VetCareHealthGenerator

  LINK = ""

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def generate(exclusive)
    city = lead.city || lead.try(:zip_code).try(:primary_city) || 'X'
    state = lead.state || lead.try(:zip_code).try(:state) || 'X'

    if lead.address_1.nil?
      address = 'X'
    else
      address = lead.address_1
    end

    query = {
      :FirstName => lead.first_name,
      :LastName => lead.last_name,
      :Address => address,
      :City => city,
      :State => state,
      :Zip => lead.zip,
      :Phone => lead.day_phone,
      :Email => lead.email,
      :ContactMethod => "E",
      :misc_code => "PI-" + lead.id.to_s
    }

    query = generate_pet_query query
    
    return query
  end

  def generate_pet_query (query)
    idx = 1;
    lead.details_pets.each do |pet|
      idx_str = idx.ordinalise.capitalize

      query[idx_str+"PetType"] = pet.species.downcase
      query[idx_str+"Breed"] = pet.breed
      query[idx_str+"PetDOB"] = pet.birth_month.to_s + "/" + pet.birth_year.to_s
      query[idx_str+"PetGender"] = pet.gender.chr
      query[idx_str+"PetName"] = pet.pet_name
      query[idx_str+"Spay"] = pet.spayed_or_neutered ? 'Y' : 'N'

      idx = idx + 1
    end

    if idx > 3
      query["FourPlus"] = "on"
    else
      query["FourPlus"] = "off"
    end

    return query
  end

end

