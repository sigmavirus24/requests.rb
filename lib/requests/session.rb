require 'net/http'
require 'net/https'
require 'requests/request'
require 'requests/structs'
require 'requests/response'

module Requests
  DEFAULT_REDIRECT_LIMIT = 30
  REDIRECT_STATI = [301, 302, 305, 307].freeze

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
      r = Request.new(method, url, args)
      p = r.prepare()
      return send(p)
    end

    def send(prep)
      req = nil
      case prep.method
      when :get
        req = Net::HTTP::Get.new(prep.uri.request_uri)
      when :post
        req = Net::HTTP::Post.new(prep.uri.request_uri)
      when :put
        req = Net::HTTP::Put.new(prep.uri.request_uri)
      when :options
        req = Net::HTTP::Options.new(prep.uri.request_uri)
      end

      body = prep.body
      unless body.nil? or body.empty? or [:options, :head].member? prep.method
        req.body = body
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

      r = resolve_redirects(r) unless r.nil?
      return r
    end

    def resolve_redirects(response)
      if REDIRECT_STATI.member? response.code
        url = response.headers['location']
        prep = PreparedRequest.new
        prep.prepare_url(url, {})
        prep.method = response.request.method
        prep.headers = response.request.headers
        # This needs to be fixed
        prep.body = response.request.body

        r = send(prep)
        r.history.push response
        response = r
      end

      return response
    end
  end
end
