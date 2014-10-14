class Visitor < ActiveRecord::Base

  validates :session_hash, presence: true
  has_many :leads
end
