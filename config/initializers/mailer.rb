# ActionMailer::Base.default_url_options[:host] = Settings.server_url

unless Rails.env.test?
  ActionMailer::Base.smtp_settings = {
      address:   'smtp.mandrillapp.com',
      port:      587,
      user_name: 'pavlo.vavruk@gmail.com',
      password:  'AWf4dDGf9L'
  }
end