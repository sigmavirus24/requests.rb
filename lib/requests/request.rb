require 'uri'
require 'securerandom'
require 'requests/structs'
require 'requests/exceptions'

module Requests
  class Request
    attr_accessor :method, :url, :headers, :files, :data, :params, :cookies

    def initialize(method, url, headers=nil, files=nil, data=nil, params=nil, cookies=nil)
      @method = method
      @url = url
      @headers = headers || Hash.new
      @files = files || Hash.new
      @data = data || Hash.new
      @params = params || Hash.new
      @cookies = cookies || Hash.new
    end

    def prepare()
      p = PreparedRequest.new
      p.prepare_method @method
      p.prepare_url @url, @params
      p.prepare_headers @headers
      p.prepare_body @data, @files
      return p
    end
  end

  class PreparedRequest
    attr_accessor :method, :uri, :headers, :body

    def initialize()
      @method = @uri = @headers = @body = nil
    end

    def prepare_method(method)
      if not method.nil?
        @method = method.upcase
      end
    end

    def url
      @uri.to_s
    end

    def prepare_url(url, params)
      @uri = URI(url)

      if @uri.scheme.nil?
        raise MissingScheme.new "Invalid URL #{url}: No scheme supplied"
      end

      if @uri.host.nil?
        raise InvalidURL.new "URL has no host (netloc)"
      end

      if @uri.path.nil?
        @uri.path = "/"
      end

      params = encode_params params
      if @uri.query
        @uri.query <<= "&#{params}"
      else
        @uri.query = params
      end
    end

    def prepare_headers(headers)
      @headers = Headers.new headers
      @headers['User-Agent'] ||= 'requests.rb/0.0.0'
    end

    def prepare_body(data, files)
      if not files.nil? and not files.empty?
        #@body, content_type = encode_files(data, files)
        #@headers['Content-Type'] = content_type
        raise NotImplementedError "multipart/form-data bodies have not yet been implemented"
      else
        @body = encode_params(data)
      end
    end

    private
    def encode_params(params)
      if params.respond_to? :each
        query_string = []
        params.each { |k, v| query_string <<= "#{k}=#{v}" }
        return query_string.empty? ? nil : query_string.join("&")
      else
        return params
      end
    end

    def encode_files(data, files)
      #combined = []
      #boundary = SecureRandom.uuid.gsub(/-/, '')
      #content_type = "multipart/form-data; boundary=#{boundary}"
      #data.each do |k, v|
      #  if v.is_a? Array
      #    v.each { |j| combined <<= [k, j] }
      #  else
      #    combined <<= [k, j]
      #  end
      #end

      #files.each do |k, v|
      #  type = nil
      #  if v.is_a? Array
      #    if v.length == 2
      #      name, pointer = v
      #    else
      #      name, pointer, type = v
      #    end
      #  else
      #    name = k
      #    pointer = v
      #  end

      #  if pointer.respond_to? read
      #    pointer = pointer.read
      #  end

      #  combined <<= [k, type.nil? ? [name, pointer] : [name, pointer, type]]
      #end

      #combined.each do |k, v|
      #  body = "--#{boundary}\r\n"

      #  if v.is_a? Array
      #    if v.length == 2
      #    end
      #  end
      #end
      #return body, content_type
    end
  end
end
