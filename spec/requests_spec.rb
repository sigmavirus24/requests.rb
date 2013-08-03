require 'requests'
include Requests

def httpbin *args
  args.unshift ENV["HTTPBIN_URL"] || "https://httpbin.org"
  args.join "/"
end

describe Requests do
  it 'makes simple GET requests' do 
    response = Requests.get httpbin('get')
    response.json.should_not be_empty
  end

  it 'makes simple POST requests' do
    response = Requests.post httpbin('post'), data: { foo: 'bar' }
    response.json['form'].should eq({ "foo" => "bar" })
  end

  it 'makes multipart/form-data POST requests' do
    response = Requests.post httpbin('post'), data: { foo: 'bar'}, files: { f: 'data' }
    response.json['form'].should eq({ "foo" => "bar" })
    response.json['files'].should eq({ "f" => "data" })
  end

  describe PreparedRequest do
    it 'encodes using multipart/form-data' do
      request = PreparedRequest.new
      request.prepare_headers Hash.new
      request.prepare_body(
        Hash.new,
        {file: 'baz'}
      )
      request.headers.include?('Content-Type').should be_true
      request.headers['Content-Type'].should match %r|^multipart/form-data; boundary=\S+$|
      request.headers['Content-Type'] =~ /^.*boundary=(.*)$/
      boundary = $1
      request.body.should eq "--#{boundary}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n\r\nbaz\r\n--#{boundary}--\r\n"
    end
  end
end
