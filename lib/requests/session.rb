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

    def inspect
      '<Requests::Session:0x%08x>' % self.object_id
    end

    def request(method, url, args={})
    #def request(method,
    #            url,
    #            headers=Requests::Headers.new,
    #            files=nil,
    #            data=nil,
    #            cookies=nil)
      r = Request.new(method, url, args)
      p = r.prepare()
      return send(p)
    end

    def send(prep)
      req = nil
      case prep.method
      when :GET
        req = Net::HTTP::Get.new(prep.uri.request_uri)
      when :POST
        req = Net::HTTP::Post.new(prep.uri.request_uri)
      when :PUT
        req = Net::HTTP::Put.new(prep.uri.request_uri)
      when :OPTIONS
        req = Net::HTTP::Options.new(prep.uri.request_uri)
      end

      unless prep.body.nil? or prep.body.empty?
        req.body = prep.body
        req.content_type = prep.headers['content-type']
      end

      # Set headers
      prep.headers.each_header { |k, v| req[k] = v }

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
