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

require 'capybara/poltergeist'
require 'phantomjs'
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs: Phantomjs.path)
end
Capybara.current_driver = :poltergeist
Capybara.app_host = 'http://gethealthcare.co/'
Capybara.default_max_wait_time = 10
