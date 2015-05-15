ActiveAdmin.register BlockList do

  menu priority: 2

  permit_params :block_ip, :active, :description

  index do
    selectable_column
    id_column
    column :block_ip
    column :active
    column :description
    column "created_at" do |block|
      UTCToPST(block.created_at)
    end

    actions
  end

end
