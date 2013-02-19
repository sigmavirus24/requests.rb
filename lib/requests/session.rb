require 'net/http'
require 'requests/request'
require 'requests/structs'

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

      prep.headers.each { |k, v| req[k] = v }

      http = Net::HTTP.start(prep.uri.host, prep.uri.port, :use_ssl => (prep.uri.scheme == 'https'))
      return http.request(req) if !req.nil?
    end
  end
end
