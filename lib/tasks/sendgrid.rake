namespace :sendgrid do

  task :contacts_custom_fields => :environment do
    sg = SendGrid::API.new(api_key: Settings.sendgrid_api_key)
    fields = [
      { name: 'Zip', type: 'text' },
      { name: 'Birth_Date', type: 'date' },
      { name: 'Gender', type: 'text' },
      { name: 'Lead_Type', type: 'text' },
      { name: 'FPL', type: 'text' },
      { name: 'Life_Event', type: 'text' }
    ]
    fields.each do |field|
      response = sg.client.contactdb.custom_fields.post(request_body: field)
      p response.status_code
      p response.body
    end
  end

end
