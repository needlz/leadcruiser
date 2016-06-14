# == Schema Information
#
# Table name: block_lists
#
#  id          :integer          not null, primary key
#  block_ip    :string(255)
#  active      :boolean
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class BlockList < ActiveRecord::Base

  validates :block_ip, presence: true
end
