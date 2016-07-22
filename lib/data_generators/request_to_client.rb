require 'net/http'
require 'uri'

class RequestToClient

  attr_accessor :lead, :client
  attr_reader :response

  def do_request(exclusive, client)
    @client = client
    @response = perform_http_request(exclusive)
  end

  def request_url
    client.service_url.nil? ? link : client.service_url
  end

  def request_header
    if client.request_type == "JSON"
      { 'Content-type' => 'application/json' }
    elsif client.request_type == "XML"
      { 'Content-type' => 'application/xml' }
    end
  end

  def perform_http_request(exclusive)
    if Rails.env.development
      'response'
    else
      HTTParty.post request_url,
                    body: generate(exclusive),
                    headers: request_header,
                    timeout: client.timeout
    end
  end

  def success?
    response["success"]
  end

  def rejection_reason
    "Test Failure"
  end

end

