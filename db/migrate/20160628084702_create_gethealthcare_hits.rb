class CreateGethealthcareHits < ActiveRecord::Migration
  def change
    create_table :gethealthcare_hits do |t|
      t.string :result
      t.text :last_error
      t.datetime :finished_at

      t.timestamps
    end
  end
end
