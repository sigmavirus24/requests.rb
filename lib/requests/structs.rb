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
    include Net::HTTPHeader
    def initialize(cookies=nil)
      if cookies.respond_to? :each
        cookies.each { |c| add_field(c.name, c) }
      else
        initialize_http_header(nil)
      end
    end

    def add_cookie(cookie, name=nil)
      if (not cookie.is_a? CGI::Cookie or cookie.nil?) and name.nil?
        raise ValueError "Must provide a cookie"
      end

      name ||= cookie.name
      add_field(name, cookie)
    end
  end
end
