require 'requests/session'

module Requests
  def self.request(method, url, *args)
    # Constructs and sends a Request
    #
    # @param method [String] method for the new Request
    # @param url [String] the URL for the new Request
    # @param data [Hash, Array, String] Hash object to send in the body of the
    #   Request
    # @param headers [Hash] Hash of HTTP Headers to send with the Request
    # @param cookies [Hash, CookieJar]  Object with cookies to be sent with
    #   the Request
    # @param files [Hash] Hash of 'name' => file-like-objects for multipart
    #   encoding
    # @param auth [Array] Array to enable Basic/Digest/Custom HTTP Auth
    # @param timeout [Fixnum, Float] describes the timeout of the request
    # @param allow_redirects [TrueClass, FalseClass] Set to ``true`` to allow
    #   redirects
    # @param proxies [Hash] mapping of protocol to the URL of the proxy
    # @param verify [TrueClass, FalseClass] determines whether certificate
    #   verification is performed
    # @param stream [TrueClass, FalseClass] determines whether or not the body
    #   should be streamed
    # @param cert [String] path to SSL client certificate file
    # @example Send a request
    #   response = Requests.request('GET', 'http://httpbin.org/get')
    #   # => <Requests::Response 200 http://httpbin.org/get>
    s = Session.new
    s.request(method, url, *args)
  end

  def self.get(url, *args)
    args[-1][:allow_redirects] ||= true
    request('get', url, *args)
  end

  def self.options(url, *args)
    args[-1][:allow_redirects] ||= true
    request('options', url, *args)
  end

  def self.head(url, *args)
    args[-1][:allow_redirects] ||= false
    request('head', url, *args)
  end

  def self.post(url, data=nil, *args)
    request('post', url, data=data, *args)
  end

  def self.put(url, *args)
    request('put', url, *args)
  end

  def self.patch(url, data=nil, *args)
    request('patch', data=data, *args)
  end

  def self.delete(url, *args)
    request('delete', url, *args)
  end
end
