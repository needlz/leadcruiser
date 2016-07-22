class ForwardHealthInsuranceLead

  def self.perform(lead)
    Vertical.health_insurance.purchase_orders.active.each do |purchase_order|
      client = purchase_order.clients_vertical

      return if client.boberdoo? && EditableConfiguration.global.inside_afterhours_range?

      delay_for_client = client.lead_forwarding_delay_seconds
      if delay_for_client > 0
        ForwardLeadToClientRequest.perform_in(delay_for_client, lead.id, purchase_order.id)
      else
        ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
      end
    end
  end

end
