namespace :leads_forwarding do

  task schedule: :environment do
    ForwardLeadsToBoberdooJob.schedule(minimal_postpone: EditableConfiguration.global.forwarding_interval_minutes.minutes)
  end

end
