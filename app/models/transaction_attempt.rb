class TransactionAttempt < ActiveRecord::Base

  belongs_to :lead
  belongs_to :purchase_order
  belongs_to :response
  belongs_to :clients_vertical, foreign_key: 'client_id', primary_key: 'id'

end