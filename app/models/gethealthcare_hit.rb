# == Schema Information
#
# Table name: gethealthcare_hits
#
#  id          :integer          not null, primary key
#  result      :string
#  last_error  :text
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  lead_id     :integer
#

class GethealthcareHit < ActiveRecord::Base
  belongs_to :lead

  def duration
    finished_at - created_at if finished_at && created_at
  end

end
