class Lead < ActiveRecord::Base
  include ErrorMessages

  after_create :send_email

  validates :site_id, :vertical_id, :first_name, :last_name, :zip, :day_phone, :email, presence: true

  belongs_to :visitor, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_many :details_pets


  def send_email
    UserMailer.new.lead_creating(self)
  end
end
