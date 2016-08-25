class ForwardLeadToClientRequest
  include Sidekiq::Worker
  sidekiq_options queue: "low"

  def perform(lead_id, purchase_order_id)
    lead = Lead.find(lead_id)
    purchase_order = PurchaseOrder.find(purchase_order_id)
    client = purchase_order.clients_vertical
    request_data = RequestToClientGenerator.new(lead, client)

    start = Time.now

    begin
      response = request_data.send_data
    rescue StandardError => e
      Rollbar.error(e)
      lead.update_attributes!(status: Lead::INVALID)
    end

    if RequestToClientGenerator::HANDLED_CONNECTION_ERRORS.values.include?(response)
      ForwardLeadToClientRequest.perform_in(10.seconds, lead_id, purchase_order_id)
    end
    finish = Time.now
    diff = finish - start

    SendPetDataWorker.check_response(response, lead, request_data.generator, client, purchase_order, diff)
  end

end
