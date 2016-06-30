Sidekiq.configure_server do |config|
  config.redis = { size: 9 }
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, storage: :redis
  end

  config.redis = { url: ENV['REDISTOGO_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'], size: 1 }
end

# Capybara::Webkit.configure do |config|
#   config.allow_unknown_urls
#   config.timeout = 20
#   config.skip_image_loading
# end
# Capybara.current_driver = :webkit_debug
# Capybara.current_driver = :selenium
require 'capybara/poltergeist';
require 'phantomjs'
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
end
Capybara.current_driver = :poltergeist
Capybara.app_host = "http://gethealthcare.co/"

# if (Rails.env.staging? || Rails.env.production?)
#   GethealthcareFormMonitor.new.perform
# end
