class PetFirstGenerator

  LINK = ENV["PET_FIRST_LINK"]

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end


  def generate
    # FirstName : string
    # LastName: string
    # Phone: string
    # Email: string
    # ZipCode: string
    # PetsCovered: string
    # Pet1BDay: string
    # Pet1Name: string
    # Pet2BDay: string
    # Pet2Name: string
    # Pet3BDay: string
    # Pet3Name: string
    # PlanSelected: string
    # Company: string
    # Coverage: string
    # LoyaltyCard: string
    # WorkPhone: string
    # CellPhone: string
    # StreetAddress1: string
    # StreetAddress2: string
    # HeardOption: string
    # EnrollmentCode: string
    # PlanDeductible: string
    # PlanCopay: string
    # PaymentType: string
    # Annual/Monthly: string
    # AdditionalInfo: string
    # Pet1Breed: string
    # Pet1Species: string
    # Pet2Breed: string
    # Pet2Species: string
    # Pet3Breed: string
    # Pet3Species: string
    # LeadId: string
    data = {
      :FirstName => lead.first_name,
      :LastName => lead.last_name,
      :Email => lead.email,
      :Phone => lead.day_phone,
      :ZipCode => lead.zip,
      :LeadId => lead.id.to_s,
      :PetsCovered => lead.details_pets.first.species,
      :Pet1BDay => lead.details_pets.first.birth_year.to_s,
      :Pet1Name => lead.details_pets.first.pet_name,
      :Pet1Breed => lead.details_pets.first.breed,
      :Pet1Breed => lead.details_pets.first.species
    }.to_json
  end

end