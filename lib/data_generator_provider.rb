require 'uri'

class DataGeneratorProvider
  attr_accessor :lead, :client

  def initialize(lead, client)
    @lead = lead
    @client = client
  end

  def data_to_send
    "#{client.integration_name}_generator".camelize.constantize.new(lead).generate
  end

  def link
    "#{client.integration_name}_generator".camelize.constantize::LINK
  end

  def int_name
    "#{client.integration_name}_generator"
  end

  def send_data
    return if client.service_url.nil? && link.blank?
    
    proxy_uri = URI.parse(ENV["PROXIMO_URL"])
    response = HTTParty.post request_url,
                  :body => data_to_send,
                  :http_proxyaddr => proxy_uri.host,
                  :http_proxyport => proxy_uri.port,
                  :http_proxyuser => proxy_uri.password,
                  :http_proxypass => proxy_uri.port,
                  :headers => request_header

    return response
  end

  private

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

end