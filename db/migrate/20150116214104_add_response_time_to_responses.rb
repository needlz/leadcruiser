class AddResponseTimeToResponses < ActiveRecord::Migration
  def change
  	add_column :responses, :response_time, :float
  end
end
