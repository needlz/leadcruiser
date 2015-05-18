class BlockList < ActiveRecord::Base

  validates :block_ip, presence: true
end