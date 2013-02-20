require 'json'

module Requests
  class Response
    attr_reader :code, :reason, :headers, :request, :url, :encoding

    def initialize(http_response, request)
      @code = http_response.code.to_i
      @reason = http_response.message
      @headers = Headers.new
      http_response.each_header { |k, v| @headers.add_field(k, v) }
      @original_response = http_response
      @url = request.url
      @request = request
      get_encoding_from_headers
    end

    def inspect
      "<Requests::Response #{@code} #{@url}>"
    end

    def content_length
      @original_response.content_length
    end

    def json
      body = @original_response.body
      return JSON.parse body
    end

    private
    def get_encoding_from_headers
      content_type = @headers['Content-Type']
      return unless content_type

      parts = content_type.split('; ')
      type = parts.shift
      params_hash = Hash.new
      parts.each do |v|
        key, val = v.split('=')
        params_hash[key] = val
      end

      @encoding = params_hash['charset'] if params_hash.key?'charset'
      @encoding = 'ISO-8859-1' if type.include? 'text'
    end
  end
end
