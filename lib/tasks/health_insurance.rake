namespace :health_insurance do
  task :seed_clients => :environment do
    ActiveRecord::Base.transaction do
      vertical = Vertical.find_by_name('health_insurance')
      vertical = Vertical.create!(name: 'health_insurance', times_sold: 0) unless vertical
      client = ClientsVertical.find_by_integration_name('boberdoo')
      client = ClientsVertical.create!(vertical_id: vertical.id,
                              integration_name: 'boberdoo',
                              active: true,
                              service_url: 'https://leads.presidiointeractive.com/genericPostlead.php',
                              request_type: 'XML',
                              display: true,
                              exclusive: true,
                              timeout: 10) unless client
      Site.create!(domain: 'gethealthcare.co', host: 'getHealthcare') unless Site.find_by_host('getHealthcare')
      tracking_page = TrackingPage.find_by_link('http://gethealthcare.co')
      tracking_page = TrackingPage.create!(link: 'http://gethealthcare.co',
                                           clients_vertical_id: client.id) unless tracking_page
      ClicksPurchaseOrder.create!(total_count: 0,
                                  daily_count: 0,
                                  price: 1, #TODO
                                  clients_vertical_id: client.id,
                                  page_id: tracking_page.id,
                                  active: true) unless ClicksPurchaseOrder.find_by_page_id(tracking_page.id)
      PurchaseOrder.create!(vertical_id: vertical.id,
                            exclusive: true,
                            states: '',
                            price: 1,
                            active: true,
                            leads_count_sold: 0,
                            daily_leads_count: 0,
                            client_id: client.id) unless PurchaseOrder.find_by_client_id(client.id) #TODO
    end
  end
end