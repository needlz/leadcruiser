require 'mandrill_mailer'

module Mandrill
  class StubbedAPI < API
    cattr_reader(:requests) { [] }

    attr_writer :response_to_return

    def initialize
    end

    def last_request
      @@requests.last
    end

    def self.last_request
      requests.last
    end

    def call(_, params = {})
      @@requests << params
      response_to_return
    end

    private

    def response_to_return
      @response_to_return ||=[{
                                  'email'         => 'recipient@example.com',
                                  'status'        => 'sent',
                                  '_id'           => 'c0eb17a66ce8430295ee6ce714e44d33',
                                  'reject_reason' => nil
                              }]
    end
  end
end


module MandrillMailer
  def api
    @api ||= Mandrill::StubbedAPI.new
  end
end