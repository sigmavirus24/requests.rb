require 'requests'

def httpbin *args
  args.unshift ENV["HTTPBIN_URL"] || "https://httpbin.org"
  args.join "/"
end

describe Requests do
  it 'makes simple GET requests' do 
    response = Requests.get httpbin 'get'
    expect(response.json).to_not be_empty
  end

  it 'makes simple POST requests' do
    response = Requests.post httpbin('post'), data: { foo: 'bar' }
    expect(response.json['form']).to eq({ "foo" => "bar" })
  end
end
