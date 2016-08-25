class RequestToClientGenerator

  attr_accessor :lead, :client
  attr_reader :generator

  NON_ENCODE_QUERY_STRING_NORMALIZER = Proc.new do |query|
    query.map do |key, value|
      if key.to_s.downcase.include? 'email'
        "#{key}=#{value}"
      else
        "#{key}=#{ERB::Util.url_encode(value)}"
      end
    end.join('&')
  end

  DEFAULT_EXCLUSIVENESS = true
  HANDLED_CONNECTION_ERRORS = {
    IOError => 'IOError',
    Net::ReadTimeout => 'Timeout',
    Net::OpenTimeout => 'Timeout'
  }

  def initialize(lead, client)
    @lead = lead
    @client = client
  end

  def data_to_send(exclusive)
    generator_class.new(lead).generate exclusive
  end

  def link
    generator_class::LINK
  end

  def generator_class
    "request_to_#{ client.integration_name }".camelize.constantize
  end

  def send_data(exclusive = DEFAULT_EXCLUSIVENESS)
    return if client.service_url.nil? && link.blank?

    response = nil
    begin
      @generator = generator_class.new(lead)
      response = generator.do_request(exclusive, client)
    rescue *(HANDLED_CONNECTION_ERRORS.keys) => e
      response = HANDLED_CONNECTION_ERRORS[e.class]
    end
    response
  end

end
