class AddLeadsCount
  attr_reader :purchase_order, :clients_vertical, :purchase_order_attributes

  def initialize(purchase_order)
    @purchase_order = purchase_order
    @clients_vertical = purchase_order.clients_vertical
    @purchase_order_attributes = {}
  end

  def perform
    ActiveRecord::Base.transaction do
      update_total_leads_count
      update_daily_leads_count
      save
    end
  end

  def responses_from_today_present?
    purchase_order.successful_responses_by_day(Date.current).exists?
  end

  def update_total_leads_count
    current_count = purchase_order.leads_count_sold || 0
    purchase_order_attributes[:leads_count_sold] = current_count + 1
  end

  def update_daily_leads_count
    current_count = purchase_order.daily_leads_count || 0
    if responses_from_today_present?
      purchase_order_attributes[:daily_leads_count] = current_count + 1
    else
      purchase_order_attributes[:daily_leads_count] = 1
    end
  end

  def save
    purchase_order.update_attributes!(purchase_order_attributes)
  end

end
