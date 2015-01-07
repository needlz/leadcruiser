class TestSuccess1Generator

  LINK = ""

  attr_accessor :lead

  def initialize(lead)
    @lead = lead
  end

  def generate(exclusive)
    {}.to_json
  end

end