namespace :health_insurance do

  task :seed_healthcare_records => :environment do
    ActiveRecord::Base.transaction do
      vertical = Vertical.find_by_name('health_insurance')
      vertical = Vertical.create!(name: 'health_insurance', times_sold: 0) unless vertical
      Site.create!(domain: 'gethealthcare.co', host: 'getHealthcare') unless Site.find_by_host('getHealthcare')
      tracking_page = TrackingPage.find_by_link('http://gethealthcare.co')
      TrackingPage.create!(link: 'http://gethealthcare.co') unless tracking_page
    end
  end


  task :seed_boberdoo_records => :environment do
    ActiveRecord::Base.transaction do
      vertical = Vertical.find_by_name('health_insurance')
      client = ClientsVertical.find_by_integration_name('boberdoo')
      client = ClientsVertical.create!(vertical_id: vertical.id,
                              integration_name: 'boberdoo',
                              active: true,
                              service_url: 'https://leads.presidiointeractive.com/genericPostlead.php',
                              request_type: '',
                              display: true,
                              exclusive: true,
                              lead_forwarding_delay_seconds: 30,
                              timeout: 10) unless client
      tracking_page = TrackingPage.find_by_link('http://gethealthcare.co')
      ClicksPurchaseOrder.create!(total_count: 0,
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

  task :seed_velocify_records => :environment do
    ActiveRecord::Base.transaction do
      vertical = Vertical.find_by_name('health_insurance')
      client = ClientsVertical.find_by_integration_name('velocify')
      client = ClientsVertical.create!(vertical_id: vertical.id,
                                       integration_name: 'velocify',
                                       active: true,
                                       service_url: 'https://secure.velocify.com/Import.aspx',
                                       request_type: '',
                                       display: true,
                                       exclusive: true,
                                       lead_forwarding_delay_seconds: 0,
                                       timeout: 10) unless client
      tracking_page = TrackingPage.find_by_link('http://gethealthcare.co')
      ClicksPurchaseOrder.create!(total_count: 0,
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
                            client_id: client.id) unless PurchaseOrder.find_by_client_id(client.id)
    end
  end

end
