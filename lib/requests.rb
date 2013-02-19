require 'requests/request'
require 'requests/session'


module Requests
  def self.get(url)
    session = Session.new
    return session.request('get', url)
  end
end
