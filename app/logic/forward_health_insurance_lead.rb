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
    forward_purchase_orders(purchase_orders, options)
  end

  def forward_to_all_except(integration_names)
    purchase_orders = Vertical.health_insurance.purchase_orders.active.
      joins(:clients_vertical).where.not(clients_verticals: { integration_name: integration_names })
    forward_purchase_orders(purchase_orders)
  end

  def forward_purchase_orders(purchase_orders, options = {})
    filtered_purchase_orders(purchase_orders).each do |purchase_order|
      client = purchase_order.clients_vertical

      next if client.boberdoo? && ForwardingTimeRange.inside_afterhours_range?

      forward_to_client_delay_aware(client, purchase_order, options)
    end
  end

  def filtered_purchase_orders(purchase_orders)
    state = lead.state || lead.try(:zip_code).try(:state)
    purchase_orders.select do |purchase_order|
      if purchase_order.states.present?
        states = purchase_order.states_array
        states.map(&:strip!)
        next if states.present? and !states.include?(state)
      end

      next if boolean?(purchase_order.preexisting_conditions) &&
          purchase_order.preexisting_conditions != (lead.health_insurance_lead.preexisting_conditions == 'yes')

      # Check Maximum leads limit
      if purchase_order.leads_max_limit.present? &&
          purchase_order.leads_count_sold.present? &&
          purchase_order.leads_count_sold >= purchase_order.leads_max_limit
        next
      end

      # Check Daily leads limit
      if purchase_order.leads_daily_limit.present? &&
          purchase_order.daily_leads_count.present? &&
          purchase_order.daily_leads_count >= purchase_order.leads_daily_limit
        next
      end

      # Check day and time
      time_filter = PurchaseOrderTimeFilter.new(purchase_order, Time.current)
      unless time_filter.allow?
        next
      end

      # Check Date
      if purchase_order.start_date.present? and purchase_order.start_date > Date.today
        next
      end

      if purchase_order.end_date.present? and purchase_order.end_date < Date.today
        next
      end

      true
    end
  end

  def boolean?(value)
    value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
  end

  def forwardable_to_ICD?
    lead.health_insurance_lead.lead_type == 'Health Insurance' && lead.health_insurance_lead.src == 'HealthMatchup'
  end

  def forward_to_client_delay_aware(client, purchase_order, options = {})
    delay_for_client = client.lead_forwarding_delay_seconds
    if delay_for_client > 0
      ForwardLeadToClientRequest.perform_in(delay_for_client, lead.id, purchase_order.id)
    else
      ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
    end
  end

end
