class PurchaseOrder < ActiveRecord::Base
  
  belongs_to :vertical
  has_many :responses
  has_many :transaction_attempts

  belongs_to :clients_vertical, foreign_key: 'client_id', primary_key: 'id'

  def states_array
    states_str = read_attribute(:states)
    if states_str.blank?
      return ""
    end

    states_array = states_str.split(/,/)
    states_array.compact
  end

  def states_array=(values)
    write_attribute(:states, values[1..-1].join(","))
  end
end
