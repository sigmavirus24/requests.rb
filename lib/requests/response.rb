begin
  require 'json'
rescue LoadError
  JSON = nil
end

module Requests
  class Response
    attr_reader :code, :reason, :headers, :request, :url, :encoding, :cookies
    attr_reader :original_response
    attr_accessor :history

    def initialize(http_response, request)
      @code = http_response.code.to_i
      @reason = http_response.message
      @headers = Headers.new
      http_response.each_header { |k, v| @headers.add_field(k, v) }
      # Original Net::HTTPResponse object
      @original_response = http_response
      # Make it easier to get the URL
      @url = request.url
      # Store request
      @request = request

      @cookies = CookieJar.new
      # Parse cookies
      @headers.get_fields('set-cookie').each do |c|
        cookie = CGI::Cookie.parse c
        unless cookie.key? 'name'
          i = c.index '='
          cookie['name'] = c[0...i]
        end
        cookie = CGI::Cookie.new cookie
        @cookies.add_cookie cookie.name, cookie
      end unless @headers.get_fields('set-cookie').nil?

      get_encoding_from_headers

      @history = Array.new
    end

    def inspect
      "<Requests::Response #{@code} #{@url}>"
    end

    def content_length
      @original_response.content_length
    end

    def json
      body = @original_response.body
      return JSON.parse body unless JSON.nil?
    end

    def body
      @original_response.body
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
