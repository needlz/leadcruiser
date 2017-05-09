# == Schema Information
#
# Table name: responses
#
#  id                :integer          not null, primary key
#  response          :text
#  rejection_reasons :text
#  created_at        :datetime
#  updated_at        :datetime
#  lead_id           :integer
#  client_name       :string(255)
#  price             :float
#  purchase_order_id :integer
#  response_time     :float
#

class Response < ActiveRecord::Base
	
	# after_commit :send_email, on: :create

	belongs_to :lead
	belongs_to :purchase_order
	belongs_to :client, class_name: 'ClientsVertical', foreign_key: 'client_name', primary_key: 'integration_name'

	has_many :transaction_attempts

	scope :successful, -> { where(rejection_reasons: nil) }

end
