require 'net/http'

module Requests
  DEFAULT_REDIRECT_LIMIT = 30

  class Session
    def initialize
      @headers = Hash.new
      @proxies = Hash.new
      @max_redirects = DEFAULT_REDIRECT_LIMIT
      @adapters = Hash.new
    end
  end
end

## Break up the URL
#u = URI(url)
#
#req = nil
#case method
#when 'get'
#  req = Net::HTTP::Get.new u.request_uri
#when 'post'
#  req = Net::HTTP::Post.new u.request_uri
#when 'put'
#  req = Net::HTTP::Put.new u.request_uri
#end
#
#http = Net::HTTP.start(u.host, u.port, :use_ssl => (u.scheme == 'https'))
#http.request(req) if !req.nil?
