# == Schema Information
#
# Table name: visitors
#
#  id               :integer          not null, primary key
#  session_hash     :string(255)
#  site_id          :integer
#  visitor_ip       :string(255)
#  referring_url    :text
#  referring_domain :string(255)
#  landing_page     :string(255)
#  keywords         :string(255)
#  utm_medium       :string(255)
#  utm_source       :string(255)
#  utm_campaign     :string(255)
#  utm_term         :string(255)
#  utm_content      :string(255)
#  location         :string(255)
#  browser          :string(255)
#  os               :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Visitor < ActiveRecord::Base
  include ErrorMessages
  validates :session_hash, presence: true

  has_many :leads, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_many :clicks
end
