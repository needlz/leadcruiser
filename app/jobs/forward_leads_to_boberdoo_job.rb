class ForwardLeadsToBoberdooJob < ActiveJob::Base
  queue_as :high

  INTERVAL = 5.minutes

  def self.max_leads_per_batch
    10
  end

  def self.leads_to_be_forwarded
    Lead.without_responses_from_boberdoo.limit(max_leads_per_batch)
  end

  def self.schedule(minimal_postpone: 0)
    return unless EditableConfiguration.global.forwarding_range?
    now = Time.current
    perform_in =
      if now < EditableConfiguration.global.today_forwarding_range_start
        EditableConfiguration.global.today_forwarding_range_start
      elsif Time.current.between?(EditableConfiguration.global.today_forwarding_range_start, EditableConfiguration.global.today_forwarding_range_end)
        (Time.current + minimal_postpone).change(usec: 0)
      else
        EditableConfiguration.global.at_day(EditableConfiguration.global.forwarding_range_start, Date.current.tomorrow)
      end
    set(wait_until: perform_in).perform_later
  end

  def perform(*args)
    ForwardLeadsToBoberdooJob.schedule(minimal_postpone: INTERVAL)
    return unless EditableConfiguration.global.forwarding_range?
    return unless Time.current.between?(EditableConfiguration.global.today_forwarding_range_start, EditableConfiguration.global.today_forwarding_range_end)
    ForwardLeadsToBoberdooJob.leads_to_be_forwarded.each do |lead|
      Vertical.health_insurance.purchase_orders.active.each do |purchase_order|
        perform_for_lead_and_order(lead, purchase_order) unless lead.responses.where(purchase_order_id: purchase_order.id).exists?
      end
    end
  end

  def perform_for_lead_and_order(lead, purchase_order)
    if Rails.env.development?
      logger.info lead.id
    else
      ForwardLeadToClientRequest.new.perform(lead.id, purchase_order.id)
    end
  end

end
