$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'Mollie/ResellerAPI/Client/Version'

spec = Gem::Specification.new do |s|
  s.name = 'mollie-reseller-api-ruby'
  s.version = Mollie::ResellerAPI::Client::CLIENT_VERSION
  s.summary = 'Unofficial Mollie Reseller API Client for Ruby'
  s.description = 'For managing customer accounts and profiles by a reseller'
  s.authors = ['Rob van Dijk']
  s.email = ['info@schoudercom.nl']
  s.homepage = 'https://github.com/robvandijk/mollie-reseller-api-ruby'
  s.license = 'BSD'
  s.required_ruby_version = '>= 2.4.0'

  s.add_dependency('rest-client', '~> 2.0')
  s.add_dependency('json', '~> 2.1')
  s.add_dependency('nokogiri', '~> 1.7')

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
