class Hartville  
  extend Savon::Model

  client(
      wsdl: "http://rpdmwebservice.hartvillegroup.com:450/?WSDL",
      proxy: "http://proxy:0c9b5e5ad093-4b36-9a80-da1a9dd96dd3@proxy-54-204-5-167.proximo.io:80",
      env_namespace: 'SOAP-ENV',
      namespace_identifier: 'SOAP-ENV'
  )

  def find
    binding.pry
  end
end