ActiveAdmin.register EditableConfiguration do
  actions :all, except: [:new, :destroy]

  permit_params :gethealthcare_form_monitor_delay_minutes

  index do
    selectable_column
    id_column
    column :gethealthcare_form_monitor_delay_minutes
    column :gethealthcare_form_threshold_seconds
    column :gethealthcare_notified_recipients_comma_separated
    actions only: :edit
  end
end
