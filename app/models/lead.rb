class Lead < ActiveRecord::Base

  has_one :visitor, primary_key: 'session_hash', foreign_key: 'session_hash'
end
