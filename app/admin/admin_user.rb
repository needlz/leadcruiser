ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column "Signed at" do |admin|
      admin.current_sign_in_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
    end
    column :sign_in_count
    column "Created Date" do |admin|
      admin.created_at.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %H:%M")
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
