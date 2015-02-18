# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'queue_classic_matchers/version'

Gem::Specification.new do |spec|
  spec.name          = "queue_classic_matchers"
  spec.version       = QueueClassicMatchers::VERSION
  spec.authors       = ["Simon Mathieu"]
  spec.email         = ["simon.math@gmail.com"]
  spec.summary       = %q{RSpec Matchers and helpers for QueueClassicPlus}
  spec.description   = %q{RSpec Matchers and helpers for QueueClassicPlus}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "queue_classic", ">= 3.1.0"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
