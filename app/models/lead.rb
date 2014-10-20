require 'httparty'
class Lead < ActiveRecord::Base
  include ErrorMessages
  include HTTParty
  # after_create :send_email

  validates :site_id, :vertical_id, :first_name, :last_name, :zip, :day_phone, :email, presence: true

  belongs_to :visitor, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_one :clients_vertical, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  has_one :zip_code, foreign_key: 'zip', primary_key: 'zip'
  has_many :details_pets


  def send_email
    UserMailer.new.lead_creating(self)
  end
end
