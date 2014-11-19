class AddPriceToResponses < ActiveRecord::Migration
  def change
  	add_column :responses, :price, :float
  end
end
