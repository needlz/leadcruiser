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
        config.afterhours_range_start.try(:in_time_zone)
      end
      row :afterhours_range_end do |config|
        config.afterhours_range_end.try(:in_time_zone)
      end
      row :forwarding_range_start do |config|
        config.forwarding_range_start.try(:in_time_zone)
      end
      row :forwarding_range_end do |config|
        config.forwarding_range_end.try(:in_time_zone)
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

  form do |f|
    inputs do
      input :gethealthcare_form_monitor_delay_minutes
      input :gethealthcare_form_threshold_seconds
      input :gethealthcare_notified_recipients_comma_separated
      input :afterhours_range_start, as: :time_select, input_html: {value: Time.zone.local_to_utc(f.object.afterhours_range_start.in_time_zone) }
      input :afterhours_range_end, as: :time_select, input_html: {value: Time.zone.local_to_utc(f.object.afterhours_range_end.in_time_zone) }
      input :forwarding_range_start, as: :time_select, input_html: {value: Time.zone.local_to_utc(f.object.forwarding_range_start.in_time_zone) }
      input :forwarding_range_end, as: :time_select, input_html: {value: Time.zone.local_to_utc(f.object.forwarding_range_end.in_time_zone) }
      input :forwarding_interval_minutes
    end
    actions
  end

  controller do
    def edit
      super do |format|
        [:afterhours_range_start, :afterhours_range_end, :forwarding_range_start, :forwarding_range_end].each do |attribute|
          @editable_configuration.send("#{ attribute }=", @editable_configuration.send(attribute).try(:in_time_zone))
        end

        @editable_configuration.afterhours_range_start = @editable_configuration.afterhours_range_start.in_time_zone
        @editable_configuration.afterhours_range_start = @editable_configuration.afterhours_range_start.in_time_zone
        @editable_configuration.afterhours_range_start = @editable_configuration.afterhours_range_start.in_time_zone
      end
    end

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

  after_update do |config|
    [:afterhours_range_start, :afterhours_range_end, :forwarding_range_start, :forwarding_range_end].each do |attribute|
      value = config.send(attribute)
      if value
        config.send("#{ attribute }=", Time.zone.local_to_utc(value))
      end
      if config.forwarding_range_start_changed? || config.forwarding_range_end_changed?
        ForwardLeadsToBoberdooJob.schedule
      end
      config.save!
    end
  end

end
