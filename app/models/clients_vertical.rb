class ClientsVertical < ActiveRecord::Base
  belongs_to :lead, foreign_key: 'vertical_id', primary_key: 'vertical_id'
  belongs_to :vertical
  after_commit :refresh_queue

  def refresh_queue
    self.vertical.update_attributes(next_client: nil)
  end
end
