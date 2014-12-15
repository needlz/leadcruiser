namespace :cron do
	task :init_daily_leads_count => :environment do
    PurcharseOrder.update_all :daily_leads_count => 0
  end
end