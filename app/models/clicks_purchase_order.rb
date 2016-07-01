# == Schema Information
#
# Table name: clicks_purchase_orders
#
#  id                  :integer          not null, primary key
#  clients_vertical_id :integer
#  site_id             :integer
#  page_id             :integer
#  price               :float
#  weight              :float
#  active              :boolean
#  total_limit         :integer
#  daily_limit         :integer
#  total_count         :integer          default(0)
#  start_date          :date
#  end_date            :date
#  created_at          :datetime
#  updated_at          :datetime
#

class ClicksPurchaseOrder < ActiveRecord::Base
  belongs_to :clients_vertical, foreign_key: 'clients_vertical_id', primary_key: 'id'
  belongs_to :tracking_page, foreign_key: 'page_id', primary_key: 'id'

	scope :active_with_tracking_page, -> { where('page_id IS NOT NULL and active = true') }

  def total_price
    price.to_f + weight.to_f
  end
end
