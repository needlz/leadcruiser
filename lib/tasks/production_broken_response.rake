require './lib/data_generator_provider'
require './lib/data_generators/pet_premium_generator'

namespace :production_broken_response do

  desc "Fix production broken responses"
  task fix: :environment do
    resent_broken_lead
  end

end

def resent_broken_lead
  Lead.find(Lead.last(55).collect(&:id) - [53,54,55,57,62,65,93,92,90,88,87]).each do |lead|
    provider = DataGeneratorProvider.new(lead, 'pet_premium')
    response = provider.send_data
    Response.create(response: response.to_s, lead_id: lead.id)
  end
end
