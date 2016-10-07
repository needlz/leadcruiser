class ForwardLeadToClientRequest
  include Sidekiq::Worker
  include ActionView::Helpers::NumberHelper
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

    record(response, lead, request_data.generator, client, purchase_order, diff)
  end

  def record(response, lead, request, client, purchase_order, response_time, exclusive_selling = false)
    response_time = number_with_precision(response_time, precision: 2)
    success = false

    if response
      # Request timeout
      if response == "Timeout" || response == "IOError"
        resp_model = Response.create(
          rejection_reasons: 'Timeout',
          lead_id: lead.id,
          client_name: client.integration_name,
          response_time: response_time
        )

        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        SendPetDataWorker.record_transaction(lead_id: lead.id,
                           client_id: client.id,
                           purchase_order_id: purchase_order[:id],
                           price: po_history.price,
                           weight: po_history.weight,
                           success: false,
                           exclusive_selling: exclusive_selling,
                           reason: response,
                           response_id: resp_model.id)
        return
      end

      rejection_reasons = nil
      resp_model = Response.create(
        response: response.to_s,
        lead_id: lead.id,
        client_name: client.integration_name,
        response_time: response_time
      )
      success = request.success?
      rejection_reasons = request.rejection_reason unless success

      if success && !resp_model.nil?
        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        SendPetDataWorker.record_transaction(        lead_id: lead.id,
                                   client_id: client.id,
                                   purchase_order_id: resp_model.purchase_order_id,
                                   price: po_history.price,
                                   weight: po_history.weight,
                                   success: true,
                                   exclusive_selling: exclusive_selling,
                                   reason: nil,
                                   response_id: resp_model.id)
        success = true
      elsif !success && !resp_model.nil?
        resp_model.update_attributes :rejection_reasons => rejection_reasons

        # Record transaction history
        po_history = PurchaseOrder.find purchase_order[:id]
        SendPetDataWorker.record_transaction(        lead_id: lead.id,
                                   client_id: client.id,
                                   purchase_order_id: purchase_order[:id],
                                   price: po_history.price,
                                   weight: po_history.weight,
                                   success: false,
                                   exclusive_selling: exclusive_selling,
                                   reason: rejection_reasons,
                                   response_id: resp_model.id)
      end
    else
      po_history = PurchaseOrder.find purchase_order[:id]
      SendPetDataWorker.record_transaction(        lead_id: lead.id,
                                 client_id: client.id,
                                 purchase_order_id: purchase_order[:id],
                                 price: po_history.price,
                                 weight: po_history.weight,
                                 success: false,
                                 exclusive_selling: exclusive_selling,
                                 reason: SendPetDataWorker::NIL_RESPONSE,
                                 response_id: nil)
    end
  end

end
