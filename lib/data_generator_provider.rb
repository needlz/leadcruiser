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
    generator.new(lead).generate exclusive
  end

  def link
    generator::LINK
  end

  def generator
    "#{client.integration_name}_generator".camelize.constantize
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
      response = generator.do_request(exclusive, client)
    rescue IOError
      response = "IOError"
    rescue Net::ReadTimeout
      response = "Timeout"
    rescue Net::OpenTimeout
      response = "Timeout"
    end

    response
  end

end