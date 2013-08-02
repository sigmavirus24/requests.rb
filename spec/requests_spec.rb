require 'requests'
include Requests

def httpbin *args
  args.unshift ENV["HTTPBIN_URL"] || "https://httpbin.org"
  args.join "/"
end

describe Requests do
  it 'makes simple GET requests' do 
    response = Requests.get httpbin('get')
    expect(response.json).to_not be_empty
  end

  it 'makes simple POST requests' do
    response = Requests.post httpbin('post'), data: { foo: 'bar' }
    expect(response.json['form']).to eq({ "foo" => "bar" })
  end

  describe PreparedRequest do
    it 'encodes using multipart/form-data' do
      request = PreparedRequest.new
      request.prepare_headers Hash.new
      request.prepare_body(
        {foo: 'bar'},
        {file: 'baz'}
      )
      request.headers.include?('Content-Type').should be_true
      request.headers['Content-Type'].should match %r|^multipart/form-data; boundary=\S+$|
      request.headers['Content-Type'] =~ /^.*boundary=(.*)$/
      boundary = $1
      request.body.should eq "--#{boundary}\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\nbar\r\n--#{boundary}"
    end
  end
end
