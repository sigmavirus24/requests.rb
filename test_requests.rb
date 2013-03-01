require 'requests'
require 'test/unit'

def httpbin(*args)
  return args.insert(0, "http://httpbin.org").join("/")
end

class TestRequests < Test::Unit::TestCase
  def test_get
    response = Requests.get(httpbin('get'))
    assert_equal(200, response.code)
  end

  def test_post_urlencoded
    response = Requests.post(httpbin('post'), :data => {:foo => 'bar'})
    json = response.json()
    assert_equal(200, response.code)
    assert_equal(json['form'], {'foo' => 'bar'})
  end
end

class TestHeaders < Test::Unit::TestCase
  def setup
    @h = Requests::Headers.new
  end

  def test_downcase
    @h['Content-Length'] = '7'
    assert_equal(@h.key?('content-length'), true)
    assert_equal(@h.key?('Content-Length'), true)
    assert_equal(@h.key?('CONTENT-LENGTH'), true)
  end

  def test_includes
    #assert_includes(Requests::Headers, Net::HTTPHeader)
    assert(Requests::Headers.include?(Net::HTTPHeader), true)
  end

  def test_multiple
    @h.add_field('foo', 'bar1')
    @h.add_field('foo', 'bar2')
    assert_equal(@h.get_fields('foo'), ['bar1', 'bar2'])
  end
end
