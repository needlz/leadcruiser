ActiveAdmin.register EditableConfiguration do
  actions :all, except: [:new, :destroy]

  permit_params EditableConfiguration.column_names

  index do
    def format_time(time)
      time.strftime('%H:%M %Z')
    end

    selectable_column
    id_column
    column :gethealthcare_form_monitor_delay_minutes
    column :gethealthcare_form_threshold_seconds
    column :gethealthcare_notified_recipients_comma_separated
    column :non_forwarding_range_start do |config|
      format_time(config.non_forwarding_range_start)
    end
    column :non_forwarding_range_end do |config|
      format_time(config.non_forwarding_range_end)
    end
    column :forwarding_range_start do |config|
      format_time(config.forwarding_range_start)
    end
    column :forwarding_range_end do |config|
      format_time(config.forwarding_range_end)
    end
    actions only: :edit
  end

  before_update do |config|
    if config.forwarding_range_start_changed?
      ForwardLeadsToBoberdooJob.schedule
    end
  end

end
