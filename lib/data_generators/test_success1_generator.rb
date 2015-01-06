class TestSuccess1Generator

  LINK = ""

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def generate
    {}.to_json
  end

end