Sidekiq.configure_server do |config|
  config.poll_interval = 5

  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, storage: :redis
  end
end