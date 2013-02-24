require 'requests'
require 'test/unit'

def httpbin(*args)
  return args.insert(0, "http://httpbin.org").join("/")
end

class TestRequests < Test::Unit::TestCase
  def test_get
    response = Requests.get(httpbin 'get')
    assert_equal(200, response.code)
  end
end
