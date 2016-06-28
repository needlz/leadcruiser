ActiveAdmin.register GethealthcareHit do

  permit_params :result, :created_at, :finished_at

  filter :result
  filter :created_at
  filter :finished_at

  index do
    selectable_column
    id_column
    column :result
    column "created_at" do |block|
      UTCToPST(block.created_at)
    end
    column "finished_at" do |block|
      UTCToPST(block.created_at)
    end
    actions
  end

end
