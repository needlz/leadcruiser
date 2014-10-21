class ZipCode < ActiveRecord::Base
  belongs_to :lead, foreign_key: 'zip', primary_key: 'zip'
end
