Gem::Specification.new do |s|
  s.name = 'requests'
  s.version = '0.0.0'
  s.date = '2012-02-16'
  s.summary = 'A port of python-requests'
  s.description = 'Making HTTP easier for humans everywhere'
  s.authors = ['Ian Cordasco']
  s.email = 'graffatcolmingov@gmail.com'
  s.files = Dir.glob('lib/**/*.rb')
  s.homepage = 'https://github.com/sigmavirus24/requests.rb'
  s.required_paths = ['lib']

  s.add_dependency 'json', '~> 1.5.4'
end
