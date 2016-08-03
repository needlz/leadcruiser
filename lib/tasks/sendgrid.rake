namespace :sendgrid do

  task :contacts_custom_fields => :environment do
    sg = SendGrid::API.new(api_key: Settings.sendgrid_api_key)
    fields = [
      { name: 'zip', type: 'text' },
      { name: 'birth_date', type: 'text' },
      { name: 'gender', type: 'text' },
      { name: 'boberdoo_type', type: 'text' },
      { name: 'fpl', type: 'text' },
      { name: 'preexisting_conditions', type: 'text' },
      { name: 'created_at', type: 'date' },
    ]
    fields.each do |field|
      response = sg.client.contactdb.custom_fields.post(request_body: field)
      p response.status_code
      p response.body
    end
  end

end
