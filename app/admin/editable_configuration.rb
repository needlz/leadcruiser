ActiveAdmin.register EditableConfiguration do
  actions :all, except: [:new, :destroy]

  permit_params EditableConfiguration.column_names

  show do
    def format_time(time)
      time.strftime('%H:%M %Z')
    end

    attributes_table do
      row :gethealthcare_form_monitor_delay_minutes
      row :gethealthcare_form_threshold_seconds
      row :gethealthcare_notified_recipients_comma_separated
      row :afterhours_range_start do |config|
        format_time(config.afterhours_range_start)
      end
      row :afterhours_range_end do |config|
        format_time(config.afterhours_range_end)
      end
      row :forwarding_range_start do |config|
        format_time(config.forwarding_range_start)
      end
      row :forwarding_range_end do |config|
        format_time(config.forwarding_range_end)
      end
      row :forwarding_interval_minutes
      row 'Leads to be frowarded' do
        ForwardLeadsToBoberdooJob.not_yet_forwarded_leads.count
      end
      row 'Leads per forward request' do
        ForwardLeadsToBoberdooJob.leads_per_batch
      end
    end
  end

  controller do
    def index
      redirect_to(controller: 'admin/editable_configurations', action: 'show', id: EditableConfiguration.global.id)
    end

    def update
        names = %w[afterhours_range_start afterhours_range_end forwarding_range_start forwarding_range_end]
        names.each do |name|
          if params[:editable_configuration]["#{ name }(4i)"].blank? || params[:editable_configuration]["#{ name }(5i)"].blank?
            params[:editable_configuration]["#{ name }(5i)"] = ''
            params[:editable_configuration]["#{ name }(4i)"] = ''
            params[:editable_configuration]["#{ name }(3i)"] = ''
            params[:editable_configuration]["#{ name }(2i)"] = ''
            params[:editable_configuration]["#{ name }(1i)"] = ''
          end
        end
      super
    end
  end

  before_update do |config|
    if config.forwarding_range_start_changed?
      ForwardLeadsToBoberdooJob.schedule
    end
  end

end
