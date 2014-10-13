class Visitor < ActiveRecord::Base

  validates :session_hash, presence: true
  has_one :lead, foreign_key: 'session_hash', primary_key: 'session_hash'
end
