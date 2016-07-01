class GethealthcareHit < ActiveRecord::Base
  belongs_to :lead

  def duration
    finished_at - created_at if finished_at && created_at
  end

end
