# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'switchless_broker_api/version'

Gem::Specification.new do |spec|
  spec.name          = "switchless_broker_api"
  spec.version       = SwitchlessBrokerApi::VERSION
  spec.authors       = ["Switchless"]
  spec.email         = ["code@switchless.com"]
  spec.description   = %q{A small lib to excersize the switchless broker api}
  spec.summary       = %q{The Switchless broker is a service that provides and executes real time quotes of Bitcoin transactions to trusted partners/clients}
  spec.homepage      = "https://switchless.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "faraday"
end
