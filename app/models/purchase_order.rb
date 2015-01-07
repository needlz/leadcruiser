class PurchaseOrder < ActiveRecord::Base
  
  belongs_to :vertical
  has_many :responses
  has_many :transaction_attemps

end
