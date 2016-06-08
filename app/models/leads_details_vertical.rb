# == Schema Information
#
# Table name: leads_details_verticals
#
#  id          :integer          not null, primary key
#  lead_id     :integer
#  detail_id   :integer
#  vertical_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class LeadsDetailsVertical < ActiveRecord::Base
end
