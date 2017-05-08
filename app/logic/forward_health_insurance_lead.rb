class ForwardHealthInsuranceLead
  attr_reader :lead

  def self.perform(lead)
    new(lead).perform
  end

  def initialize(lead)
    @lead = lead
  end

  def perform
    if forwardable_to_ICD?
      forward_to(['insurance_care_direct'])
      forward_to_all_except(['insurance_care_direct'])
    else
      forward_to_all_except(['insurance_care_direct'])
    end
  end

  def forward_to(integration_names, options = {})
    purchase_orders = Vertical.health_insurance.purchase_orders.active.
      joins(:clients_vertical).where(clients_verticals: { integration_name: integration_names })
    forward_purchace_orders(purchase_orders, options)
  end

  def forward_to_all_except(integration_names)
    purchase_orders = Vertical.health_insurance.purchase_orders.active.
      joins(:clients_vertical).where.not(clients_verticals: { integration_name: integration_names })
    forward_purchace_orders(purchase_orders)
  end

  def forward_purchace_orders(purchace_orders, options = {})
    purchace_orders.each do |purchase_order|
      client = purchase_order.clients_vertical

      next if client.boberdoo? && ForwardingTimeRange.inside_afterhours_range?

      forward_to_client_delay_aware(client, purchase_order, options)
    end
  end

  def forwardable_to_ICD?
    lead.health_insurance_lead.lead_type == 'Health Insurance' && lead.health_insurance_lead.src == 'HealthMatchup'
  end

  def forward_to_client_delay_aware(client, purchase_order, options = {})
    delay_for_client = options[:delay_seconds] || client.lead_forwarding_delay_seconds
    if delay_for_client > 0
      ForwardLeadToClientRequest.perform_in(delay_for_client, lead.id, purchase_order.id)
    else
      ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
    end
  end

end
