# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stackr/version'

Gem::Specification.new do |spec|
  spec.name          = "stackr"
  spec.version       = Stackr::VERSION
  spec.authors       = ["Chris Chalfant"]
  spec.email         = ["cchalfant@leafsoftwaresolutions.com"]

  spec.summary       = %q{Framework for managing CloudFormation stacks}
  spec.description   = %q{Framework for managing CloudFormation stacks}
  spec.homepage      = "https://github.com/LeafSoftware/stackr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk"
  spec.add_dependency "cloudformation-ruby-dsl"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
