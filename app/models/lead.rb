require 'httparty'
require 'workers/send_email_worker.rb'
class Lead < ActiveRecord::Base
  include ErrorMessages

  after_commit :send_email, on: :create
  before_save :check_uniqueness_of_pet

  validates :site_id, :vertical_id, :first_name, :last_name, :zip, :day_phone, :email, presence: true

  belongs_to :visitor, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_one :clients_vertical, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  has_one :zip_code, foreign_key: 'zip', primary_key: 'zip'
  has_many :details_pets

  def send_email
    SendEmailWorker.perform_async(self.id)
  end

  def check_uniqueness_of_pet
    return false unless pet_insurance?

    leads = Lead.where(email: email).includes(:details_pets)
    return true unless leads.exists?

    leads.each do |lead|
      lead.details_pets.each do |pet|
        next unless self.details_pets.any? { |new_pet| new_pet.validate_same(pet) }
        return false
      end
    end

    true
   end

  private

  def pet_insurance?
    vertical_id == 1
  end
end
