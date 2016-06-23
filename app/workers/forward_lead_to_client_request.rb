class ForwardLeadToClientRequest
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def perform(lead_id, purchase_order_id)
    lead = Lead.find(lead_id)
    purchase_order = PurchaseOrder.find(purchase_order_id)
    client = purchase_order.clients_vertical
    request_data = RequestToClientGenerator.new(lead, client)

    start = Time.now
    request_data.send_data
    finish = Time.now
    diff = finish - start

    save_response(lead, request_data.generator, client, purchase_order, diff)

    # Check Responses table and return with JSON response
    response_list = Response.where("lead_id = ? and rejection_reasons IS NULL", lead.id)
    lead.update_attributes(status: Lead::NO_POS) if response_list.blank?
  end

  def save_response(*args)
    SendDataWorker.check_response(*args)
  end

end
