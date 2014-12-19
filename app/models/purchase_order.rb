class PurchaseOrder < ActiveRecord::Base
  
  belongs_to :vertical
  has_many :responses

end
