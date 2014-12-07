require 'httparty'

class WebServiceRequest
  include HTTParty
  base_uri 'rpdmwebservice.hartvillegroup.com:450'

  def post_request(path, option)
    response = self.class.post(path, option)
  end
end