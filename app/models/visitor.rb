class Visitor < ActiveRecord::Base
  include ErrorMessages
  validates :session_hash, presence: true

  has_many :leads, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_many :clicks
end
