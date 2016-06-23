# == Schema Information
#
# Table name: clients_verticals
#
#  id                :integer          not null, primary key
#  vertical_id       :integer
#  integration_name  :string(255)
#  active            :boolean
#  weight            :integer
#  exclusive         :boolean
#  fixed_price       :float
#  created_at        :datetime
#  updated_at        :datetime
#  service_url       :string(255)
#  request_type      :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  email             :string(255)
#  phone_number      :string(255)
#  website_url       :string(255)
#  official_name     :string(255)
#  description       :text
#  sort_order        :integer
#  display           :boolean          default(TRUE)
#  timeout           :integer          default(20)
#

class ClientsVertical < ActiveRecord::Base

  after_commit :refresh_queue
  
  belongs_to :lead, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  belongs_to :vertical

  has_many :transaction_attempts, foreign_key: 'id', primary_key: 'client_id'
  has_many :clicks_purchase_orders

  scope :active_to_be_displayed, -> { where('display = true and active = true') }
  scope :ordered, -> { order(sort_order: :asc) }

  has_attached_file :logo,
                    :styles => {
                        :medium => "200x100>",
                        :thumb => "30x15>"
                    }

  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/
  validates :lead_forwarding_delay_seconds, numericality: { greater_than_or_equal_to: 0 }

  PET_PREMIUM   = "pet_premium"
  PET_FIRST     = "pet_first"
  PETS_BEST     = "pets_best"
  HEALTHY_PAWS  = "healthy_paws"
  VET_CARE_HEALTH = "vet_care_health"

  BOBERDOO = 'boberdoo'
  
  def refresh_queue
    self.vertical.update_attributes(next_client: nil)
  end

  def display_name
    self.integration_name
  end
end
