class PurchaseOrder < ActiveRecord::Base
  
  belongs_to :vertical
  has_many :responses
  has_many :transaction_attempts

  belongs_to :clients_vertical, foreign_key: 'client_id', primary_key: 'id'

  # def states
  #   return "" if read_attribute(:states).blank?

  #   self.read_attribute(:states)
  # end

  # def states=(states)
  #   binding.pry
  #   self[:states] = "111"
  # end

end
