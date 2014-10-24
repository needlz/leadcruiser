class DataGeneratorProvider
  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def data_to_send
    "#{@lead.clients_vertical.integration_name}_generator".camelize.constantize.new(lead).generate
  end

  def link
    "#{@lead.clients_vertical.integration_name}_generator".camelize.constantize::LINK
  end

  def send_data
    return if link.blank?
    HTTParty.post link,
                  :body => data_to_send,
                  :headers => {'Content-type' => 'application/xml'}

  end

end