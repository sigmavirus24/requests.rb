require 'net/http'
require 'cgi'
require 'requests/exceptions'


module  Requests
  class Headers
    include Net::HTTPHeader
    def initialize(initial_headers=nil)
      if initial_headers.respond_to? :each_header
        initial_headers.each_header { |k, v| v.each { |i| add_field(k, i) } }
      else
        initialize_http_header(initial_headers)
      end
    end
  end

  class CookieJar
    def initialize(cookies=nil)
      @cookies = Hash.new
    end

    def inspect
      '<Requests::CookieJar:0x%08x>' % self.object_id
    end

    def []=(key, value)
      if @cookies.key? key
        raise ValueError "Two cookies with the same name"
      end
      @cookies[key] = value
    end

    def [](key)
      @cookies[key]
    end

    def delete(key)
      @cookies.delete key
    end

    def key?(key)
      @cookies.key? key
    end

    def to_hash
      @cookies.dup
    end

    def size
      @cookies.size
    end

    def each
      @cookies.each { |k, v| yield k, v }
    end

    def add_cookie(name, cookie)
      if (not cookie.is_a? CGI::Cookie or cookie.nil?) and name.nil?
        raise ValueError "Must provide a cookie"
      end

      @cookies[name] = cookie
    end
  end
end
