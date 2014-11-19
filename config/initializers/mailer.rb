# ActionMailer::Base.default_url_options[:host] = Settings.server_url

unless Rails.env.test?
  ActionMailer::Base.smtp_settings = {
      address:   'smtp.mandrillapp.com',
      port:      587,
      user_name: 'rnatsch@gmail.com',
      password:  'presidio1presidio'
  }
end