ActiveAdmin.register ForwardingTimeRange do

  permit_params :kind, :begin_day, :begin_time, :end_day, :end_time

  show do
    def format_time(time)
      time.strftime('%H:%M %Z')
    end

    attributes_table do
      row :kind
      row :begin_day
      row :begin_time do |range|
        format_time(range.begin_time.in_time_zone)
      end
      row :end_day
      row :end_time do |range|
        format_time(range.end_time.in_time_zone)
      end
    end
  end

  index do
    def format_time(time)
      time.strftime('%H:%M %Z')
    end

    selectable_column
    id_column
    column :kind
    column :begin_day
    column 'Begin Time' do |r|
      format_time(r.begin_time.in_time_zone)
    end
    column :end_day
    column 'End Time' do |r|
      format_time(r.end_time.in_time_zone)
    end
    actions
  end

  form do |f|
    inputs do
      li "Please make sure no times overlap between selected filters"
      input :kind, as: :select, collection: [ForwardingTimeRange::FORWARDING, ForwardingTimeRange::AFTERHOURS].map { |kind| [kind, kind] }
      input :begin_day, as: :select, collection: Date::DAYNAMES.map { |daymname| [daymname, daymname] }
      input :begin_time, as: :time_select, input_html: { value: Time.zone.local_to_utc(f.object.begin_time.try(:in_time_zone, ForwardingTimeRange::TIME_ZONE)) }
      input :end_day, as: :select, collection: Date::DAYNAMES.map { |daymname| [daymname, daymname] }
      input :end_time, as: :time_select, input_html: { value: Time.zone.local_to_utc(f.object.end_time.try(:in_time_zone, ForwardingTimeRange::TIME_ZONE)) }
    end
    actions
  end

  controller do

    def edit
      super do |format|
        [:begin_time, :end_time].each do |attribute|
          @forwarding_time_range.send("#{ attribute }=", @forwarding_time_range.send(attribute).try(:in_time_zone, ForwardingTimeRange::TIME_ZONE))
        end
      end
    end

    def update
      @closest_range_before_update = ForwardingTimeRange.closest_or_current_forwarding_range
      super
    end

    def create
      @closest_range_before_update = ForwardingTimeRange.closest_or_current_forwarding_range
      super
    end

    def schedule
      ForwardLeadsToBoberdooJob.schedule
    end

  end

  before_create do |range|
    [:begin_time, :end_time].each do |attribute|
      value = range.send(attribute)
      if value
        range.send("#{ attribute }=",
                   value.in_time_zone(ForwardingTimeRange::TIME_ZONE).change(year: ForwardingTimeRange::DEFAULT_YEAR.year,
                                                 month: ForwardingTimeRange::DEFAULT_YEAR.month,
                                                 day: ForwardingTimeRange::DEFAULT_YEAR.day,
                                                 hour: params['forwarding_time_range']["#{ attribute }(4i)"],
                                                 min: params['forwarding_time_range']["#{ attribute }(5i)"])
        )
      end
    end
  end

  before_update do |range|
    [:begin_time, :end_time].each do |attribute|
      value = range.send(attribute)
      if value
        range.send("#{ attribute }=", value.in_time_zone(ForwardingTimeRange::TIME_ZONE).change(hour: params['forwarding_time_range']["#{ attribute }(4i)"],
                                                                    min: params['forwarding_time_range']["#{ attribute }(5i)"]))
      end
    end
  end

  after_create do
    schedule
  end

  after_update do
    schedule
  end

end
