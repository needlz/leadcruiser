# == Schema Information
#
# Table name: states
#
#  id   :integer          not null, primary key
#  name :string(255)
#  code :string(255)
#

class State < ActiveRecord::Base
end
