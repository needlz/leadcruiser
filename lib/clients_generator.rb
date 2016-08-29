class ClientsGenerator

  ClientAssociatedRecords = Struct.new(:client, :order)

  def self.client
    @@client.save!
    @@client
  end

  def self.order
    @@order.save!
    @@order
  end

  def self.boberdoo
    @@client = ClientsVertical.new(vertical_id: Vertical.health_insurance.id,
                            integration_name: 'boberdoo',
                            active: true,
                            service_url: 'https://leads.presidiointeractive.com/genericPostlead.php',
                            request_type: '',
                            display: true,
                            exclusive: true,
                            lead_forwarding_delay_seconds: 30,
                            timeout: 10)
    @@order = PurchaseOrder.new(vertical_id: Vertical.health_insurance.id,
                                  exclusive: true,
                                  states: '',
                                  price: 1,
                                  active: true,
                                  leads_count_sold: 0,
                                  daily_leads_count: 0,
                                  client_id: client.id)
    self
  end

  def self.velocify
    @@client = ClientsVertical.new(vertical_id: Vertical.health_insurance.id,
                            integration_name: 'velocify',
                            active: true,
                            service_url: 'https://secure.velocify.com/Import.aspx',
                            request_type: '',
                            display: true,
                            exclusive: true,
                            lead_forwarding_delay_seconds: 0,
                            timeout: 10)
    @@order = PurchaseOrder.new(vertical_id: Vertical.health_insurance.id,
                                  exclusive: true,
                                  states: '',
                                  price: 1,
                                  active: true,
                                  leads_count_sold: 0,
                                  daily_leads_count: 0,
                                  client_id: client.id)
    self
  end

  def self.five9
    @@client = ClientsVertical.new(vertical_id: Vertical.health_insurance.id,
                            integration_name: 'five9',
                            active: true,
                            service_url: 'https://api.five9.com/web2campaign/AddToList',
                            request_type: '',
                            display: true,
                            exclusive: true,
                            lead_forwarding_delay_seconds: 0,
                            timeout: 10)
    @@order = PurchaseOrder.new(vertical_id: Vertical.health_insurance.id,
                                  exclusive: true,
                                  states: '',
                                  price: 1,
                                  active: true,
                                  leads_count_sold: 0,
                                  daily_leads_count: 0,
                                  client_id: client.id)
    self
  end

end
