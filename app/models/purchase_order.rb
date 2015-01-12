class PurchaseOrder < ActiveRecord::Base
  
  belongs_to :vertical
  has_many :responses
  has_many :transaction_attempts

  belongs_to :clients_vertical, foreign_key: 'client_id', primary_key: 'id'

end
