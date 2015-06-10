lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'terraform_dsl/version'

Gem::Specification.new do |spec|
  spec.name        = 'terraform_dsl'
  spec.version     = Terraform::VERSION
  spec.summary     = 'Wrap hashicorps "terraform" in a ruby DSL for managing stack templates'
  spec.description = 'Terraform DSL provides a syntax for managing terraform infrastructure entirely in git'
  spec.authors     = ['Dale Hamel']
  spec.email       = 'dale.hamel@srvthe.net'
  spec.files       = Dir['lib/**/*']
  spec.homepage    = 'https://rubygems.org/gems/terraform_dsl'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rake', '~> 10.4'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '~> 5.6'
end
