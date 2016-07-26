ActiveAdmin.register AdminUser do

  menu priority: 2

  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column "Signed at" do |admin|
      admin.current_sign_in_at
    end
    column :sign_in_count
    column "Created Date" do |admin|
      admin.created_at
    end
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
