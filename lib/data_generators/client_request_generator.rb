require 'net/http'
require 'uri'

class ClientRequestGenerator

  attr_accessor :lead, :client

  def do_request(exclusive, client)
    @client = client
    perform_http_request(exclusive)
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
    HTTParty.post request_url,
                  :body => generate(exclusive),
                  :headers => request_header,
                  :timeout => client.timeout
  end

end

