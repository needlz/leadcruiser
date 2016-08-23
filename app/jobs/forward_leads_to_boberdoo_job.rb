class ForwardLeadsToBoberdooJob
  include Sidekiq::Worker
  sidekiq_options queue: 'high', unique: :until_and_while_executing

  DEFAULT_INTERVAL_MINUTES = 5

  attr_reader :purchase_order, :client

  def self.not_yet_forwarded_leads
    Lead.health_insurance.without_responses_from_boberdoo.where(status: nil)
  end

  def self.schedule(minimal_postpone: 0)
    return unless ForwardingTimeRange.any_forwarding_range?
    now = Time.current
    perform_time =
      if now < ForwardingTimeRange.closest_or_current_forwarding_range[:start]
        ForwardingTimeRange.closest_or_current_forwarding_range[:start]
      elsif ForwardingTimeRange.inside_forwarding_range?
        (Time.current + minimal_postpone)
      else
        ForwardingTimeRange.closest_forwarding_range[:start]
      end
    perform_at(perform_time)
  end

  def perform(*args)
    return unless ForwardingTimeRange.any_forwarding_range?
    return unless ForwardingTimeRange.inside_forwarding_range?
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
    return unless ForwardingTimeRange.any_forwarding_range?
    interval = EditableConfiguration.global.forwarding_interval_minutes || DEFAULT_INTERVAL_MINUTES
    needed_requests_count = (ForwardingTimeRange.mins_till_end_of_closest_forwarding_range.to_f / interval).ceil
    return if needed_requests_count.zero?
    (ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.count.to_f / needed_requests_count).ceil
  end

  def forward_lead(lead)
    begin
      perform_for_lead_and_order(lead) unless lead.responses.where(purchase_order_id: purchase_order.id).exists?
      @processed += 1
    rescue StandardError => e
      Rollbar.error(e)
      lead.update_attributes!(status: Lead::INVALID)
    end
  end

  def forward_leads
    limit = ForwardLeadsToBoberdooJob.leads_per_batch
    @processed = 0
    leads = ForwardLeadsToBoberdooJob.not_yet_forwarded_leads
    leads.each do |lead|
      forward_lead(lead)
      break if @processed >= limit
    end
  end

end
