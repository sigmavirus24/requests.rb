module Requests
  class Response
    def initialize(http_response)
      @code = http_response.code.to_i
      @reason = "#{http_response.code} #{http_response.message}"
      @headers = Headers.new http_response
      #http_response.each_header { |k, v| @headers[k] = v }
      @original_response = http_response
    end
  end
end
