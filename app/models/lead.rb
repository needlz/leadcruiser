class Lead < ActiveRecord::Base

  validates :session_hash, presence: true
  belongs_to :visitor, primary_key: 'session_hash', foreign_key: 'session_hash'
end
