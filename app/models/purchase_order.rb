# == Schema Information
#
# Table name: purchase_orders
#
#  id                     :integer          not null, primary key
#  vertical_id            :integer
#  weight                 :float
#  exclusive              :boolean
#  states                 :string(255)
#  preexisting_conditions :boolean
#  price                  :float
#  status                 :string(255)
#  active                 :boolean
#  leads_max_limit        :integer
#  leads_daily_limit      :integer
#  leads_count_sold       :integer          default(0)
#  daily_leads_count      :integer          default(0)
#  start_date             :date
#  end_date               :date
#  created_at             :datetime
#  updated_at             :datetime
#  client_id              :integer
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
      return ""
    end

    states_str.split(/,\s+/)
  end

  def states_array=(values)
    write_attribute(:states, values[1..-1].join(", "))
  end
end
