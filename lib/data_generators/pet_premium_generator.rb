require 'nokogiri'

class PetPremiumGenerator

  LINK = ENV["PET_PREMIUM_LINK"]

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end


  def generate
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.LeadData( Target: 'Lead.Insert', Partner: ENV["PET_PREMIUM_EMAIL"], Password: ENV["PET_PREMIUM_PASSWORD"], RequestTime: DateTime.now.strftime('%Y-%m-%d %H:%M:%S') ) do
        xml.AffiliateData(Id: lead.id, OfferId: lead.id, VerifyAddress: "false", RespondOnNoSale: "true", LeadId: lead.id, Source: 'All')
        generate_contact_data_xml(xml)
        xml.QuoteRequest(QuoteType: 'Pet') do
          generate_owners_xml(xml)
          generate_pets_xml(xml)
        end
      end
    end
    builder.to_xml
  end

  private

  def generate_contact_data_xml(xml)
    xml.ContactData do
      xml.send(:FirstName, lead.first_name)
      xml.send(:LastName, lead.last_name)
      xml.send(:Address, lead.address_1 || 'No address was provided')
      xml.send(:City, lead.city || lead.try(:zip_code).try(:primary_city) || 'No city was provided')
      xml.send(:State, lead.state || lead.try(:zip_code).try(:state) || 'No state was provided')
      xml.send(:ZIPCode, lead.zip)
      xml.send(:EmailAddress, lead.email)
      xml.send(:PhoneNumber, lead.day_phone)
      xml.send(:IPAddress, lead.try(:visitor).try(:visitor_ip) || '127.1.1.1')
      xml.send(:FirstName, lead.first_name)
      xml.send(:LastName, lead.last_name)
      xml.send(:BirthDate, lead.birth_date)
      xml.send(:Gender, lead.gender)
    end
  end

  def generate_owners_xml(xml)
    xml.Owners do
        xml.Owner do
          xml.send(:FirstName, lead.first_name)
          xml.send(:LastName, lead.last_name)
        end
    end
  end

  def generate_pets_xml(xml)
    xml.Pets do
      lead.details_pets.each do |pet|
        pet_type = pet.species.capitalize
        xml.Pet do
          xml.send(:Species, pet.species)
          xml.send(:SpayedOrNeutered, pet.spayed?)
          xml.send(:PetName, pet.pet_name)
          xml.send("#{pet_type}BirthMonth", Date::ABBR_MONTHNAMES[pet.birth_month])
          xml.send("#{pet_type}BirthDay", pet.birth_day)
          xml.send("#{pet_type}BirthYear", pet.birth_year)
          xml.send("#{pet_type}Breed", pet.breed_to_send('pet_premium'))
          xml.send("#{pet_type}Gender", pet.gender)
          xml.send("#{pet_type}Conditions", pet.conditions?)
        end
      end
    end
  end

end