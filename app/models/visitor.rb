class Visitor < ActiveRecord::Base

  validates :session_hash, presence: true

end
