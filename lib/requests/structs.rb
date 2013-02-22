require 'net/http'


module  Requests
  class Headers
    include Net::HTTPHeader
    def initialize(initial_headers=nil)
      if initial_headers.respond_to? :each_header
        initial_headers.each_header { |k, v| v.each { |i| add_field(k, i) } }
      else
        initialize_http_header(initial_headers)
      end
    end
  end
end
