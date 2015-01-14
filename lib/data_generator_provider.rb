require 'net/http'
require 'uri'

class DataGeneratorProvider
  attr_accessor :lead, :client

  def initialize(lead, client)
    @lead = lead
    @client = client
  end

  def data_to_send(exclusive)
    "#{client.integration_name}_generator".camelize.constantize.new(lead).generate exclusive
  end

  def link
    "#{client.integration_name}_generator".camelize.constantize::LINK
  end

  def int_name
    "#{client.integration_name}_generator"
  end

  def send_data (exclusive=true)
    return if client.service_url.nil? && link.blank?

    ########## For Hartville from here ##############
    # proxy_uri = URI.parse(ENV["PROXIMO_URL"])
    # data = HTTParty.post request_url,
    #               :body => data_to_send,
    #               :http_proxyaddr => proxy_uri.host,
    #               :http_proxyport => proxy_uri.port,
    #               :http_proxyuser => proxy_uri.user,
    #               :http_proxypass => proxy_uri.password,
    #               :headers => { 'Content-type' => 'application/soap+xml' }
    # binding.pry
    # url = URI(request_url)
    # req = Net::HTTP::Post.new(url.path)
    # # req.content_type = 'application/x-www-form-urlencoded'
    # req.content_type = 'application/soap+xml'
    # req.body = data_to_send
    # # req.content_length = data_to_send.bytesize().to_s()
    # binding.pry
    # proxy = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
    # response = proxy.start(url.hostname, url.port) {|http| 
    #   binding.pry
    #   http.request(req) 
    # }
    # binding.pry
    
    ########## True code ##################
    if client.integration_name == ClientsVertical::PETS_BEST
      return HTTParty.get request_url, :query => data_to_send(exclusive)
    elsif client.integration_name == ClientsVertical::HEALTHY_PAWS
      return HTTParty.get request_url, :query => data_to_send(exclusive), :headers => request_header
    else
      return HTTParty.post request_url,
                    :body => data_to_send(exclusive),
                    :headers => request_header
    end
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