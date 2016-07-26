ActiveAdmin.setup do |config|
  config.before_filter :set_admin_timezone
end
