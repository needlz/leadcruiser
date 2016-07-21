class HealthInsuranceMailWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high'

  def perform(mailer_method, *args)
    HealthInsuranceMailer.new.send(mailer_method, *args)
  end
end
