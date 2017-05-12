# == Schema Information
#
# Table name: transaction_attempts
#
#  id                :integer          not null, primary key
#  lead_id           :integer
#  client_id         :integer
#  purchase_order_id :integer
#  price             :float
#  success           :boolean
#  exclusive_selling :boolean
#  reason            :text
#  response_id       :integer
#  created_at        :datetime
#  updated_at        :datetime
#  weight            :float
#

class TransactionAttempt < ActiveRecord::Base

  belongs_to :lead
  belongs_to :purchase_order
  belongs_to :response
  belongs_to :clients_vertical, foreign_key: 'client_id', primary_key: 'id'

  scope :successful, -> { where(success: true) }

end
