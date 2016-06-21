class ForwardHealthInsuranceLead

  def self.perform(lead)
    Vertical.health_insurance.purchase_orders.active.each do |purchase_order|
      client = purchase_order.clients_vertical
      delay_for_client = Settings.request_delays.try(client.integration_name)
      if delay_for_client
        ForwardLeadToClientRequest.perform_in(delay_for_client, lead.id, purchase_order.id)
      else
        ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
      end
    end
  end

end
