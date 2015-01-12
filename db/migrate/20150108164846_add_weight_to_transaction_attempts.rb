class AddWeightToTransactionAttempts < ActiveRecord::Migration
  def change
  	add_column :transaction_attempts, :weight, :float
  end
end
