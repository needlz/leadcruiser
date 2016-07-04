require File.expand_path('../boot', __FILE__)

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Leadcruiser
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    autoload_paths = %w[app/logic lib/data_generators app/workers lib lib/workers]
    config.autoload_paths += autoload_paths.map { |dir| "#{ config.root }/#{ dir }" }
    config.middleware.use ActionDispatch::Flash
    config.api_only = false

    Kaminari.configure do |config|
      config.page_method_name = :per_page_kaminari
    end

    Obscenity.configure do |config|
      config.blacklist   = "config/blacklist.yml"
    end

    config.active_record.raise_in_transactional_callbacks = true
  end
end
