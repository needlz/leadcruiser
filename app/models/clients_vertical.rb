class ClientsVertical < ActiveRecord::Base

  after_commit :refresh_queue
  
  belongs_to :lead, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  belongs_to :vertical

  has_many :transaction_attempts, foreign_key: 'id', primary_key: 'client_id'

  has_attached_file :logo,
                    :styles => {
                        :medium => "200x100>",
                        :thumb => "30x15>"
                    }

  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

  PET_PREMIUM   = "pet_premium"
  PET_FIRST     = "pet_first"
  PETS_BEST     = "pets_best"
  HEALTHY_PAWS  = "healthy_paws"
  VET_CARE_HEALTH = "vet_care_health"
  
  def refresh_queue
    self.vertical.update_attributes(next_client: nil)
  end

  def display_name
    self.integration_name
  end
end
