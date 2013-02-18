#require 'uri'
#require 'net/http'
#
#module Requests
#  def self.request(method, url)
#    # Break up the URL
#    u = URI(url)
#
#    req = nil
#    case method
#    when 'get'
#      req = Net::HTTP::Get.new u.request_uri
#    when 'post'
#      req = Net::HTTP::Post.new u.request_uri
#    when 'put'
#      req = Net::HTTP::Put.new u.request_uri
#    end
#
#    http = Net::HTTP.start(u.host, u.port, :use_ssl => (u.scheme == 'https'))
#    http.request(req) if !req.nil?
#  end
#
#  def self.get(url)
#    request('get', url)
#  end
#
#  def self.post(url)
#    request('post', url)
#  end
#
#  def self.put(url)
#    request('put', url)
#  end
#end

require 'requests/request'
