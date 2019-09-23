# == Schema Information
#
# Table name: purchase_orders
#
#  id                       :integer          not null, primary key
#  vertical_id              :integer
#  weight                   :float
#  exclusive                :boolean
#  states                   :string(255)
#  preexisting_conditions   :boolean
#  price                    :float
#  status                   :string(255)
#  active                   :boolean
#  leads_max_limit          :integer
#  leads_daily_limit        :integer
#  leads_count_sold         :integer          default(0)
#  daily_leads_count        :integer          default(0)
#  start_date               :date
#  end_date                 :date
#  created_at               :datetime
#  updated_at               :datetime
#  client_id                :integer
#  sunday_filter_enabled    :boolean
#  sunday_begin_time        :time
#  sunday_end_time          :time
#  monday_filter_enabled    :boolean
#  monday_begin_time        :time
#  monday_end_time          :time
#  tuesday_filter_enabled   :boolean
#  tuesday_begin_time       :time
#  tuesday_end_time         :time
#  wednesday_filter_enabled :boolean
#  wednesday_begin_time     :time
#  wednesday_end_time       :time
#  thursday_filter_enabled  :boolean
#  thursday_begin_time      :time
#  thursday_end_time        :time
#  friday_filter_enabled    :boolean
#  friday_begin_time        :time
#  friday_end_time          :time
#  saturday_filter_enabled  :boolean
#  saturday_begin_time      :time
#  saturday_end_time        :time
#  daily_limit_date         :date
#

class PurchaseOrder < ActiveRecord::Base
  
  belongs_to :vertical
  has_many :responses
  has_many :transaction_attempts

  belongs_to :clients_vertical, foreign_key: 'client_id', primary_key: 'id'

  scope :active, -> { where(active: true) }

  def states_array
    states_str = read_attribute(:states)
    if states_str.blank?
      return []
    end

    states_str.split(/,\s+/)
  end

  def states_array=(values)
    write_attribute(:states, values[1..-1].join(", "))
  end

  def price_string
    Lead::PRICE_PRECISION % price.to_f
  end

  def successful_responses_by_day(date)
    transaction_attempts.where(created_at: date.beginning_of_day..date.end_of_day).successful
  end

end
