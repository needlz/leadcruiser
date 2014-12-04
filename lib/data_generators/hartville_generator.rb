require 'nokogiri'

class HartvilleGenerator

  LINK = ""

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def generate
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.root do
        xml.row do
          generate_contact_data_xml(xml)
          generate_pets_xml(xml)
        end
      end
    end

    builder.to_xml
  end

  private

  def generate_contact_data_xml(xml)
    xml.send(:SessionID, '')
    xml.send(:ProductPhone, '')
    xml.send(:Station, '')
    xml.send(:ProductCode, '')
    xml.send(:CallDate, lead.created_at.strftime("%m/%d/%Y"))
    xml.send(:CallTime, lead.created_at.strftime("%H%M"))
    xml.send(:TRANSFERED, 'Yes')
    xml.send(:ANI, '')
    xml.send(:MailingFirstName, lead.first_name)
    xml.send(:MailingLastName, lead.last_name)
    xml.send(:MailingAddress1, lead.address_1 || 'No address was provided')
    xml.send(:MailingAddress2, lead.address_2 || 'No address was provided')
    xml.send(:MailingCity, lead.city || lead.try(:zip_code).try(:primary_city) || 'No city was provided')
    xml.send(:MailingState, lead.state || lead.try(:zip_code).try(:state) || 'No state was provided')
    xml.send(:MailingZipCode, lead.zip)
    xml.send(:MailingCountry, '')
    xml.send(:MailingPhone, lead.day_phone)
    xml.send(:EmailAddress, lead.email)
  end

  def generate_pets_xml(xml)
    cat_qty = lead.details_pets.where('species = ?', 'Cat')
    dog_qty = lead.details_pets.where('species = ?', 'Dog')

    xml.send(:DogQty, dog_qty)
    xml.send(:CatQty, cat_qty)
    xml.send(:TimeTocall, 0)

    for i in 1..5
      pet = lead.details_pets[i-1]
      unless pet.nil?
        xml.send("Pet#{i}Name", pet.pet_name)
        xml.send("Pet#{i}Breed", pet.breed_to_send('hartville'))
        xml.send("Pet#{i}BreedId", 0)
        xml.send("Pet#{i}Age_Years", pet.birth_year)
        xml.send("Pet#{i}Age_Months", pet.birth_month)
        xml.send("Pet#{i}PreExisting", pet.conditions == 'Yes' ? 1 : 0)
      else
        xml.send("Pet#{i}Name", '')
        xml.send("Pet#{i}Breed", '')
        xml.send("Pet#{i}BreedId", 0)
        xml.send("Pet#{i}Age_Years", 0)
        xml.send("Pet#{i}Age_Months", 0)
        xml.send("Pet#{i}PreExisting", 0)
      end
    end
  end

end