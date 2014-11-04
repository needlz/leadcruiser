class DataGeneratorProvider
  attr_accessor :lead, :integration_name

  def initialize(lead, integration_name)
    @lead = lead
    @integration_name = integration_name
  end

  def data_to_send
    "#{integration_name}_generator".camelize.constantize.new(lead).generate
  end

  def link
    "#{integration_name}_generator".camelize.constantize::LINK
  end

  def int_name
    "#{integration_name}_generator"
  end

  def send_data
    return if link.blank?
    HTTParty.post link,
                  :body => data_to_send,
                  :headers => {'Content-type' => 'application/xml'}

  end

end