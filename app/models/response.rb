# == Schema Information
#
# Table name: responses
#
#  id                  :integer          not null, primary key
#  response            :text
#  client_times_sold   :string(255)
#  client_offer_amount :string(255)
#  client_offer_accept :boolean
#  error_reasons       :text
#  rejection_reasons   :text
#  created_at          :datetime
#  updated_at          :datetime
#  lead_id             :integer
#  client_name         :string(255)
#  price               :float
#  purchase_order_id   :integer
#  response_time       :float
#

class Response < ActiveRecord::Base
	
	# after_commit :send_email, on: :create

	belongs_to :lead
	belongs_to :purchase_order

	has_many :transaction_attempts

end
