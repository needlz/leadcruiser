class ClientsVertical < ActiveRecord::Base
  belongs_to :lead, foreign_key: 'vertical_id', primary_key: 'vertical_id'
end
