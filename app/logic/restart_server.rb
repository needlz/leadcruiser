class RestartServer

  def self.perform
    heroku_api = PlatformAPI.connect(Settings.heroku.api_key)
    heroku_api.dyno.restart_all(Settings.heroku.app_name)
  end

end
