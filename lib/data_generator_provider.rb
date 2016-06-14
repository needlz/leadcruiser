require 'net/http'
require 'uri'

class DataGeneratorProvider
  attr_accessor :lead, :client

  NON_ENCODE_QUERY_STRING_NORMALIZER = Proc.new do |query|
    query.map do |key, value|
      if key.to_s.downcase.include? 'email'
        "#{key}=#{value}"
      else
        "#{key}=#{ERB::Util.url_encode(value)}"
      end
    end.join('&')
  end

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
    # url = URI(request_url)
    # req = Net::HTTP::Post.new(url.path)
    # # req.content_type = 'application/x-www-form-urlencoded'
    # req.content_type = 'application/soap+xml'
    # req.body = data_to_send
    # # req.content_length = data_to_send.bytesize().to_s()
    # proxy = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
    # response = proxy.start(url.hostname, url.port) {|http| 
    #   http.request(req) 
    # }
    
    ########## True code ##################
    response = nil

    begin
      if client.integration_name == ClientsVertical::VET_CARE_HEALTH
        response = HTTParty.get request_url, 
                      :query => data_to_send(exclusive), 
                      :timeout => client.timeout,
                      #:debug_output => $stdout,
                      query_string_normalizer: NON_ENCODE_QUERY_STRING_NORMALIZER

      elsif client.integration_name == ClientsVertical::PETS_BEST
        response = HTTParty.get request_url, 
                      :query => data_to_send(exclusive), 
                      :timeout => client.timeout
      elsif client.integration_name == ClientsVertical::HEALTHY_PAWS || client.integration_name == 'boberdoo'
        response = HTTParty.get request_url, 
                      :query => data_to_send(exclusive), 
                      :headers => request_header,
                      :timeout => client.timeout
      else
        response = HTTParty.post request_url,
                      :body => data_to_send(exclusive),
                      :headers => request_header,
                      :timeout => client.timeout
      end

    rescue IOError
      response = "IOError"
    rescue Net::ReadTimeout
      response = "Timeout"
    rescue Net::OpenTimeout
      response = "Timeout"
    end

    response
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