ActiveAdmin.register GethealthcareHit do

  permit_params :result, :created_at, :finished_at

  filter :result
  filter :created_at
  filter :finished_at

  index do
    selectable_column
    id_column
    column :lead_id
    column :result
    column :last_error
    column :duration
    actions
  end

end
