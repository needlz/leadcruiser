ActiveAdmin.register PurchaseOrder do

  menu priority: 3

  permitted_paramters = [:vertical_id, :client_id, :weight, :exclusive, :states, :preexisting_conditions, :price,
                         :status, :active, :leads_max_limit, :leads_daily_limit, :start_date, :end_date, :states_array => []]
  days = Date::DAYNAMES.each do |day_name|
    day = day_name.downcase
    permitted_paramters << "#{ day }_filter_enabled"
    permitted_paramters << "#{ day }_begin_time"
    permitted_paramters << "#{ day }_end_time"
  end

  permit_params *permitted_paramters

  filter :vertical
  filter :clients_vertical
  filter :exclusive
  filter :preexisting_conditions
  filter :price
  filter :active
  filter :start_date
  filter :end_date

  show do
    attributes_table do
      row :id
      row :vertical_id
      row :weight
      row :exclusive
      row :states
      row :preexisting_conditions
      row :price
      row :status
      row :active
      row :leads_max_limit
      row :leads_daily_limit
      row :leads_count_sold
      row :daily_leads_count
      row :start_date
      row :end_date
      row :created_at
      row :updated_at
      row :client_id

      Date::DAYNAMES.map(&:downcase).each do |day|
        [:begin_time, :end_time].each do |attribute|
          row "#{ day }_#{ attribute }" do |r|
            FormatTime.for(r.send("#{ day }_#{ attribute }").try(:in_time_zone))
          end
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    column :vertical_id
    column "Client" do |po|
      po.clients_vertical.try(:integration_name)
    end
    column :weight
    column :exclusive
    column :states
    column "Pre existing Conditions" do |po|
      if po.preexisting_conditions.nil?
        ""
      else
        if po.preexisting_conditions
          "Yes"
        else
          "No"
        end
      end
    end
    column :price
    column :status
    column :active
    column :leads_max_limit
    column :leads_daily_limit
    column :leads_count_sold
    column :daily_leads_count
    column "Start Date" do |po|
      unless po.start_date.nil?
        po.start_date.strftime("%Y-%m-%d")
      end
    end
    column "End Date" do |po|
      unless po.end_date.nil?
        po.end_date.strftime("%Y-%m-%d")
      end
    end

    actions
  end

  form  do |f|
    f.inputs "Purchase Order" do
      f.input :vertical
      f.input :client_id, 
              :as => :select,
              :collection => ClientsVertical.select(:integration_name, :id).uniq.pluck(:integration_name, :id)
      f.input :weight
      f.input :exclusive
      f.input :states_array,
              :as => :check_boxes,
              :collection => State.select(:name, :code).uniq.pluck(:name, :code)
      f.input :preexisting_conditions,
              :as => :select
      f.input :price
      f.input :active
      f.input :leads_max_limit
      f.input :leads_daily_limit
      f.input :start_date
      f.input :end_date


      inputs name: 'Day filters', class: 'time-filters' do
        li 'Day filters'
        days = Date::DAYNAMES.map(&:downcase).each do |day_name|
          # li day_name
          f.input "#{ day_name }_filter_enabled", as: :boolean, label: day_name.capitalize
          begin_time_method = "#{ day_name }_begin_time"
          f.input begin_time_method,
                  label: 'From time',
                  as: :time_select,
                  input_html: { value: Time.zone.local_to_utc(f.object.send(begin_time_method).try(:in_time_zone, ForwardingTimeRange::TIME_ZONE)) }
          end_time_method = "#{ day_name }_end_time"
          f.input end_time_method,
                  label: 'to',
                  as: :time_select,
                  input_html: { value: Time.zone.local_to_utc(f.object.send(end_time_method).try(:in_time_zone, ForwardingTimeRange::TIME_ZONE)) }
        end
      end
    end

    f.actions
  end

  controller do
    def edit
      super do |format|
        Date::DAYNAMES.map(&:downcase).each do |day|
          [:begin_time, :end_time].each do |attribute|
            @purchase_order.send("#{ day }_#{ attribute }=",
                                 @purchase_order.send("#{ day }_#{ attribute }").try(:in_time_zone, ForwardingTimeRange::TIME_ZONE)
            )
          end
        end
      end
    end
  end

  before_create do |range|
    Date::DAYNAMES.map(&:downcase).each do |day|
      [:begin_time, :end_time].each do |attribute|
        value = range.send("#{ day }_#{ attribute }")
        if value
          range.send("#{ day }_#{ attribute }=",
                     value.in_time_zone(ForwardingTimeRange::TIME_ZONE).
                       change(year: ForwardingTimeRange::DEFAULT_YEAR.year,
                              month: ForwardingTimeRange::DEFAULT_YEAR.month,
                              day: ForwardingTimeRange::DEFAULT_YEAR.day,
                              hour: params['purchase_order']["#{ day }_#{ attribute }(4i)"],
                              min: params['purchase_order']["#{ day }_#{ attribute }(5i)"]
                       )
          )
        end
      end
    end
  end

  before_update do |range|
    Date::DAYNAMES.map(&:downcase).each do |day|
      [:begin_time, :end_time].each do |attribute|
        value = range.send("#{ day }_#{ attribute }")
        if value && params['purchase_order']["#{ day }_#{ attribute }(4i)"].present?
          range.send("#{ day }_#{ attribute }=", value.in_time_zone(ForwardingTimeRange::TIME_ZONE).
              change(year: ForwardingTimeRange::DEFAULT_YEAR.year,
                     month: ForwardingTimeRange::DEFAULT_YEAR.month,
                     day: ForwardingTimeRange::DEFAULT_YEAR.day,
                     hour: params['purchase_order']["#{ day }_#{ attribute }(4i)"],
                     min: params['purchase_order']["#{ day }_#{ attribute }(5i)"])
          )
        else
          range.send("#{ day }_#{ attribute }=", nil)
        end
      end
    end
  end

end
