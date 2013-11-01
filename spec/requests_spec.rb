require 'requests'
require 'vcr'
include Requests

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.default_cassette_options = {
    serialize_with: :json,
    preserve_exact_body_bytes: true,
    record: ENV['TRAVIS'] ? :none : :once
  }
  c.hook_into :webmock
end

def httpbin *args
  args.unshift ENV["HTTPBIN_URL"] || "https://httpbin.org"
  args.join "/"
end

describe Requests do
  context 'when the generic API is in use' do
    it 'makes simple GET requests' do
      VCR.use_cassette('simple_get_api') do
        response = Requests.get httpbin('get')
        response.json.should_not be_empty
      end
    end

    it 'makes simple POST requests' do
      VCR.use_cassette('simple_post_api') do
        response = Requests.post httpbin('post'), data: { foo: 'bar' }
        response.json['form'].should eq({ "foo" => "bar" })
      end
    end

    it 'makes multipart/form-data POST requests' do
      VCR.use_cassette('multipart_form_data_post_api') do
        response = Requests.post(
          httpbin('post'),
          data: { foo: 'bar'},
          files: { f: 'data' }
        )
        response.json['form'].should eq({ "foo" => "bar" })
        response.json['files'].should eq({ "f" => "data" })
      end
    end
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
      request.headers['Content-Type'].should match(
        %r|^multipart/form-data; boundary=\S+$|
      )
      request.headers['Content-Type'] =~ /^.*boundary=(.*)$/
      boundary = $1
      request.body.should eq(
        "--#{boundary}\r\nContent-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n\r\nbaz\r\n--#{boundary}--\r\n"
      )
    end
  end
end
