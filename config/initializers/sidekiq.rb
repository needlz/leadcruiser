Sidekiq.configure_server do |config|
  config.poll_interval = 10

  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, storage: :redis
  end

  config.redis = { url: ENV['REDISTOGO_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'] }
end