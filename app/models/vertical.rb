class Vertical < ActiveRecord::Base
  has_many :leads
  has_many :clients_verticals
  has_many :purchase_orders
end
