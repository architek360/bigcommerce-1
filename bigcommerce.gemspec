# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bigcommerce/version'

Gem::Specification.new do |gem|
  gem.name          = "bigcommerce"
  gem.version       = Bigcommerce::VERSION
  gem.authors       = ["Adeel Ahmad"]
  gem.email         = ["adeel@shopseen.com"]
  gem.description   = %q{Wrapper for BigCommerce v2 API}
  gem.summary       = %q{Wrapper for BigCommerce v2 API}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'faraday', '~> 0.8'
  gem.add_dependency 'faraday_middleware', '~> 0.8'
  gem.add_dependency 'hashie', '~> 1.2'
  gem.add_dependency 'inflection'
end
