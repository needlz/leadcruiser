require './lib/request_to_client_generator'
require './lib/data_generators/request_to_pet_premium'

namespace :production_broken_response do

  desc "Fix production broken responses"
  task fix: :environment do
    resent_broken_lead
  end

end

def resent_broken_lead
  Lead.find(Lead.last(55).collect(&:id) - [53,54,55,57,62,65,93,92,90,88,87]).each do |lead|
    provider = RequestToClientGenerator.new(lead, 'pet_premium')
    response = provider.send_data
    Response.create(response: response.to_s, lead_id: lead.id)
  end
end
