# ActionMailer::Base.default_url_options[:host] = Settings.server_url

unless Rails.env.test?
  ActionMailer::Base.smtp_settings = {
      address:   'smtp.mandrillapp.com',
      port:      587,
      user_name: ENV["MANDRILL_USERNAME"],
      password:  ENV["MANDRILL_PASSWORD"]
  }
end