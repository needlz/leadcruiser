class ClientsVertical < ActiveRecord::Base
  
  belongs_to :lead, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  belongs_to :vertical
  after_commit :refresh_queue

  has_attached_file :logo,
                    :styles => {
                        :medium => "200x100>",
                        :thumb => "30x15>"
                    }

  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

  PET_PREMIUM   = "pet_premium"
  PET_FIRST     = "pet_first"
  PETS_BEST     = "pets_best"
  
  def refresh_queue
    self.vertical.update_attributes(next_client: nil)
  end
end
