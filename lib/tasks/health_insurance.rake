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
      client = ClientsVertical.find_by_integration_name(ClientsVertical::BOBERDOO)
      client = ClientsGenerator.boberdoo.client unless client
      tracking_page = TrackingPage.find_by_link('http://gethealthcare.co')
      ClicksPurchaseOrder.create!(total_count: 0,
                                  price: 1, #TODO
                                  clients_vertical_id: client.id,
                                  page_id: tracking_page.id,
                                  active: true) unless ClicksPurchaseOrder.find_by_page_id(tracking_page.id)
      ClientsGenerator.boberdoo.order unless PurchaseOrder.find_by_client_id(client.id)
    end
  end

  task :seed_velocify_records => :environment do
    ActiveRecord::Base.transaction do
      client = ClientsVertical.find_by_integration_name('velocify')
      client = ClientsGenerator.velocify.client unless client
      tracking_page = TrackingPage.find_by_link('http://gethealthcare.co')
      ClicksPurchaseOrder.create!(total_count: 0,
                                  price: 1, #TODO
                                  clients_vertical_id: client.id,
                                  page_id: tracking_page.id,
                                  active: true) unless ClicksPurchaseOrder.find_by_page_id(tracking_page.id)
      ClientsGenerator.velocify.order unless PurchaseOrder.find_by_client_id(client.id)
    end
  end

  task :seed_five_9_records => :environment do
    ActiveRecord::Base.transaction do
      client = ClientsVertical.find_by_integration_name('five9')
      client = ClientsGenerator.five9.client unless client
      ClientsGenerator.five9.order unless PurchaseOrder.find_by_client_id(client.id)
    end
  end

end
