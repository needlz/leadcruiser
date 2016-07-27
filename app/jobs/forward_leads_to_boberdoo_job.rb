class ForwardLeadsToBoberdooJob < ActiveJob::Base
  queue_as :high

  DEFAULT_INTERVAL_MINUTES = 5

  attr_reader :purchase_order, :client

  def self.not_yet_forwarded_leads
    Lead.health_insurance.without_responses_from_boberdoo.where(status: nil)
  end

  def self.schedule(minimal_postpone: 0)
    return unless EditableConfiguration.global.any_forwarding_range?
    now = Time.current
    perform_in =
      if now < EditableConfiguration.global.closest_or_current_forwarding_range[:start]
        EditableConfiguration.global.closest_or_current_forwarding_range[:start]
      elsif EditableConfiguration.global.inside_forwarding_range?
        (Time.current + minimal_postpone)
      else
        EditableConfiguration.global.closest_forwarding_range[:start]
      end
    set(wait_until: perform_in).perform_later
  end

  def perform(*args)
    return unless EditableConfiguration.global.any_forwarding_range?
    return unless EditableConfiguration.global.inside_forwarding_range?
    @client = ClientsVertical.find_by_integration_name(ClientsVertical::BOBERDOO)
    @purchase_order = PurchaseOrder.find_by_client_id(client.id)
    forward_leads
    ForwardLeadsToBoberdooJob.schedule(minimal_postpone: EditableConfiguration.global.forwarding_interval_minutes.minutes)
  end

  def perform_for_lead_and_order(lead)
    if Rails.env.development?
      logger.info(lead.id)
    else
      ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
    end
  end

  def self.leads_per_batch
    return unless EditableConfiguration.global.any_forwarding_range?
    interval = EditableConfiguration.global.forwarding_interval_minutes || DEFAULT_INTERVAL_MINUTES
    needed_requests_count = (EditableConfiguration.global.closest_forwarding_range_length_mins.to_f / interval).ceil
    (ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.count.to_f / needed_requests_count).ceil
  end

  def forward_lead(lead)
    begin
      perform_for_lead_and_order(lead) unless lead.responses.where(purchase_order_id: purchase_order.id).exists?
    rescue StandardError => e
      Rollbar.error(e)
    end
  end

  def forward_leads
    limit = ForwardLeadsToBoberdooJob.leads_per_batch
    leads = ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.limit(limit)
    leads.each { |lead| forward_lead(lead) }
  end

end
