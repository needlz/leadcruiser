require 'httparty'
require 'workers/send_email_worker.rb'
class Lead < ActiveRecord::Base
  include ErrorMessages
  include HTTParty
  after_commit :send_email, on: :create

  validates :site_id, :vertical_id, :first_name, :last_name, :zip, :day_phone, :email, presence: true

  belongs_to :visitor, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_one :clients_vertical, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  has_one :zip_code, foreign_key: 'zip', primary_key: 'zip'
  has_many :details_pets


  def send_email
    SendEmailWorker.perform_async(self.id)
  end

  def self.number_per_day(first_day, second_date)
    data = []
    last_date = second_date.to_i
    while last_date >= first_day.to_i do
      data << [last_date * 1000 ,Lead.by_day(DateTime.parse(Time.at(last_date).to_s)).count]
      last_date -= 1.day.to_i
    end
    data
  end

end
