# == Schema Information
#
# Table name: leads
#
#  id                :integer          not null, primary key
#  session_hash      :string(255)
#  site_id           :integer
#  form_id           :integer          default(1)
#  first_name        :string(255)
#  last_name         :string(255)
#  address_1         :string(255)
#  address_2         :string(255)
#  city              :string(255)
#  state             :string(255)
#  zip               :string(255)
#  day_phone         :string(255)
#  evening_phone     :string(255)
#  email             :string(255)
#  best_time_to_call :string(255)
#  birth_date        :datetime
#  gender            :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  times_sold        :integer
#  total_sale_amount :float
#  vertical_id       :integer
#  visitor_ip        :string(255)      default("127.1.1.1")
#  status            :string(255)
#  disposition       :string(255)
#

require 'httparty'
require 'workers/send_email_worker.rb'
class Lead < ActiveRecord::Base
  include ErrorMessages

  # after_commit :send_email, on: :create
  # before_save :check_uniqueness_of_pet
  before_save  :populate_state

  validates :site_id, :vertical_id, :first_name, :last_name, :zip, :day_phone, :email, presence: true

  belongs_to :visitor, foreign_key: 'session_hash', primary_key: 'session_hash'
  has_many :clients_verticals, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  has_one :zip_code, foreign_key: 'zip', primary_key: 'zip'
  has_many :details_pets
  belongs_to :vertical
  belongs_to :site
  has_many :responses
  has_many :transaction_attempts
  has_one :health_insurance_lead

  scope :without_responses_from_boberdoo, ->{ joins('LEFT JOIN responses ON responses.lead_id = leads.id').where.not(Response.arel_table[:client_name].eq(ClientsVertical::BOBERDOO)) }
  scope :health_insurance, ->{ where(vertical_id: Vertical.health_insurance.id) }
  scope :with_responses, ->{ joins(:responses) }

  # constant
  DUPLICATED  = "duplicated"
  SOLD        = "sold"
  BLOCKED     = "blocked"
  NO_POS      = "No Matching POs"
  TEST_NO_SALE = "Test No Sale"
  TEST_SALE   = "Test Sale"
  TEST_TERM   = "test"
  PROFANITY   = "Profanity block"
  IP_BLOCKED  = "IP block"

  PRICE_PRECISION = '%.2f'
  ZERO_PRICE = '0.00'

  # ransacker :created_at do
  #   Arel.sql("date(timezone('PST8PDT', created_at))")
  # end

  # ransacker :created_at_gteq do
  #   Arel.sql("date(timezone('UTC', created_at))")
  # end

  # ransacker :created_at_lteq do
  #   Arel.sql("date(timezone('UTC', created_at))")
  # end

  def latest_response
    Response.where('lead_id = ?', self.id).order(id: :desc).try(:first)
  end

  def sold_responses
    Response.where('lead_id = ? and price is not null', self.id).order(id: :desc)
  end

  def client_sold_to(client_name)
    ClientsVertical.where('vertical_id = ? and integration_name = ?', self.vertical_id, client_name).try(:first)
  end

  def sold_po_price(purchase_order_id)
    if PurchaseOrder.exists? purchase_order_id
      po = PurchaseOrder.find (purchase_order_id)
      # not include weight in po price
      # '%.2f' % (po.try(:price).to_f + po.try(:weight).to_f)
      PRICE_PRECISION % po.try(:price).to_f
    else
      ZERO_PRICE
    end
  end

  def sold_type
    TransactionAttempt.where('lead_id = ? and success = ?', self.id, true).try(:first)
  end

  def sold!
    update_attributes!(status: SOLD)
  end

  def sold?
    status == SOLD
  end

  def pet_insurance?
    Vertical.pet_insurance && vertical_id == Vertical.pet_insurance.id
  end

  def test?
    first_name == 'test' && last_name == 'test' && address_1 == 'test' && email == 'test@test.com'
  end

  def name
    [first_name, last_name].join(' ')
  end

  private

  def populate_state
    if self.state.nil?
      self.state = ZipCode.find_by_zip(self.zip).try(:state)
    end
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

end
