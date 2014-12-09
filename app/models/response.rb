require 'workers/send_email_worker.rb'
class Response < ActiveRecord::Base
	
	after_commit :send_email, on: :create

	belongs_to :lead

	def send_email
    SendEmailWorker.perform_async(self.id)
    # SendEmailWorker.new.perform(self.id)
  end

end
