require 'net/http'


module  Requests
  class Headers
    include Net::HTTPHeader
    def initialize(initial_headers=nil)
      initialize_http_header(initial_headers)
    end
  end
end
