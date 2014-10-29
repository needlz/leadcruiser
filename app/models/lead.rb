require 'httparty'
require 'workers/send_email_worker.rb'
class Lead < ActiveRecord::Base
  include ErrorMessages
  include HTTParty
  after_commit :send_email, on: :create
  before_save :check_uniqueness
  validates :site_id, :vertical_id, :first_name, :last_name, :zip, :day_phone, :email, presence: true

  belongs_to :visitor, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_one :clients_vertical, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  has_one :zip_code, foreign_key: 'zip', primary_key: 'zip'
  has_many :details_pets


  def send_email
    SendEmailWorker.perform_async(self.id)
  end

  def check_uniqueness
      return false unless vertical_id == 1
      lead = Lead.where(email: email)
      return true unless lead.exists?

      pets_details_of_lead = lead.map{|lead| lead.details_pets.map{|pet| "#{pet.try(:breed)}, #{pet.try(:pet_name)}"}}.flatten
      new_pets_details = self.details_pets.map{|pet| "#{pet.try(:breed)}, #{pet.try(:pet_name)}"}

      return (pets_details_of_lead & new_pets_details).empty?
  end
end
