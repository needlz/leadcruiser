class Response < ActiveRecord::Base
	
	# after_commit :send_email, on: :create

	belongs_to :lead
	belongs_to :purchase_order

	has_many :transaction_attemps

end
