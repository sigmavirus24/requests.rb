require 'uri'
require 'securerandom'
require 'requests/structs'
require 'requests/exceptions'

module Requests
  class Request
    attr_accessor :method, :url, :headers, :files, :data, :params, :cookies

    def initialize(method, url, args={})
      @method = method
      @url = url
      @headers = args[:headers] || Hash.new
      @files = args[:files] || Hash.new
      @data = args[:data] || Hash.new
      @params = args[:params] || Hash.new
      @cookies = args[:cookies] || Hash.new
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

    def initialize
      @method = @uri = @headers = @body = nil
    end

    def copy
      p = PreparedRequest.new
      p.method = @method
      p.uri = @uri
      p.headers = @headers
      p.body = @body
      return p
    end

    def prepare_method(method)
      if not method.nil?
        @method = method.to_sym
      end
    end

    def url
      @uri.to_s
    end

    def url=(request_url)
      @uri = URI(request_url)
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
      unless params
        if @uri.query
          @uri.query <<= "&#{params}"
        else
          @uri.query = params
        end
      end
    end

    def prepare_headers(headers)
      @headers = Headers.new headers
      @headers['User-Agent'] ||= 'requests.rb/0.0.0'
    end

    def prepare_body(data, files)
      if not files.empty?
        (@body, @headers['content-type']) = encode_files(data, files)
      elsif not data.empty?
        @body = encode_params(data)
        @headers['content-type'] = 'application/x-www-form-urlencoded'
      end

      unless @body.nil? or @body.empty?
        @headers['content-length'] = @body.length
      end
    end

  private
    def encode_params(params)
      if params.respond_to? :map
        return URI.encode_www_form params
      else
        # Probably a string or something that URI#encode_www_form can't handle
        return params
      end
    end

    def encode_files(data, files)
      combined = []
      boundary = SecureRandom.uuid.gsub(/-/, '')
      content_type = "multipart/form-data; boundary=#{boundary}"
      data.each do |k, v|
        if v.is_a? Array
          v.each { |j| combined <<= [k, j] }
        else
          combined <<= [k, v]
        end
      end

      files.each do |k, v|
        type = nil
        if v.is_a? Array
          if v.length == 2
            name, content = v
          else
            name, content, type = v
          end
        else
          name = k
          content = v
        end

        if content.respond_to? :read
          content = content.read
        end

        combined << [k, type.nil? ? [name, content] : [name, content, type]]
      end

      boundary = "--#{boundary}"

      combined = combined.map do |k, v|
        form_entry = ""
        form_entry << "Content-Disposition: form-data; name=\"#{k}\""

        if v.is_a? Array
          if v.length == 2
            form_entry << "; filename=\"#{v.first}\""
            content = v.last
          end
        else
          content = v
        end
        form_entry <<  "\r\n\r\n#{content}\r\n"
      end
      form = combined.join("#{boundary}\r\n")
      body = "#{boundary}\r\n#{form}#{boundary}--\r\n"
      return body, content_type
    end
  end
end
