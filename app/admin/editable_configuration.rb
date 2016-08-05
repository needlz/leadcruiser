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
    # def edit
    #   super do |format|
    #     Ranges.fullname_attributes.each do |attribute|
    #       @editable_configuration.send("#{ attribute }=", @editable_configuration.send(attribute).try(:in_time_zone))
    #     end
    #   end
    # end

    def index
      redirect_to(controller: 'admin/editable_configurations', action: 'show', id: EditableConfiguration.global.id)
    end

    # def update
    #   Ranges.fullname_attributes.each do |attribute|
    #     if params[:editable_configuration]["#{ attribute }(4i)"].blank? || params[:editable_configuration]["#{ attribute }(5i)"].blank?
    #       (1..5).each do |index|
    #         params[:editable_configuration]["#{ attribute }(#{ index }i)"] = ''
    #       end
    #     end
    #   end
    #   @closest_range_before_update = resource.closest_or_current_forwarding_range
    #   super
    # end
  end
  #
  # before_update do |config|
  #   Ranges.fullname_attributes.each do |attribute|
  #     value = config.send(attribute)
  #     if value
  #       config.send("#{ attribute }=", Time.zone.local_to_utc(value))
  #     end
  #   end
  # end
  #
  # after_update do |config|
  #   ForwardLeadsToBoberdooJob.schedule if config.closest_or_current_forwarding_range != @closest_range_before_update
  # end

end
