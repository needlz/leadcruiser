ActiveAdmin.register EditableConfiguration do
  actions :all, except: [:new, :destroy]

  permit_params EditableConfiguration.column_names if ActiveRecord::Base.connection.table_exists?('editable_configurations')

  show do
    attributes_table do
      row :gethealthcare_form_monitor_delay_minutes
      row :gethealthcare_form_threshold_seconds
      row :gethealthcare_notified_recipients_comma_separated

      row :forwarding_interval_minutes
      row 'Leads to be frowarded' do
        ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.count
      end
      row 'Leads per forward request' do
        ForwardLeadsToBoberdooJob.leads_per_batch
      end
    end
  end

  form do |f|
    inputs do
      input :gethealthcare_form_monitor_delay_minutes
      input :gethealthcare_form_threshold_seconds
      input :gethealthcare_notified_recipients_comma_separated
      input :forwarding_interval_minutes
    end
    actions
  end

  controller do
    def index
      redirect_to(controller: 'admin/editable_configurations', action: 'show', id: EditableConfiguration.global.id)
    end
  end

end
