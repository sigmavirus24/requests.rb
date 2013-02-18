require 'requests/session'

module Requests
  def self.request(method, url)
    s = Session.new
    s.request(method, url)
  end

  def self.get(url)
    request('get', url)
  end

  def self.post(url)
    request('post', url)
  end

  def self.put(url)
    request('put', url)
  end

  def self.delete(url)
    request('delete', url)
  end
end
