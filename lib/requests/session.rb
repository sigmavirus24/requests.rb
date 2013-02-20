require 'net/http'
require 'net/https'
require 'requests/request'
require 'requests/structs'
require 'requests/response'

module Requests
  DEFAULT_REDIRECT_LIMIT = 30

  class Session
    def initialize
      @headers = Headers.new
      @proxies = Hash.new
      @max_redirects = DEFAULT_REDIRECT_LIMIT
      @adapters = Hash.new
    end

    def request(method, url, headers=nil, files=nil, data=nil, cookies=nil)
      r = Request.new(method, url, headers, files, data, cookies)
      p = r.prepare()
      return send(p)
    end

    def send(prep)
      req = nil
      case prep.method
      when 'GET'
        req = Net::HTTP::Get.new(prep.uri.request_uri)
      when 'POST'
        req = Net::HTTP::Post.new(prep.uri.request_uri)
      when 'PUT'
        req = Net::HTTP::Put.new(prep.uri.request_uri)
      end

      # Set headers
      prep.headers.each { |k, v| req[k] = v }

      http = Net::HTTP.new(prep.uri.host, prep.uri.port)
      http.use_ssl = prep.uri.scheme == 'https'
      unless req.nil?
        r = Response.new(http.start { |context| context.request(req) }, prep)
      else
        r = nil
      end
      return r
    end
  end
end
