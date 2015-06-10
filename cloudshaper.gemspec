lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudshaper/version'

Gem::Specification.new do |spec|
  spec.name        = 'cloudshaper'
  spec.version     = Cloudshaper::VERSION
  spec.summary     = 'Wrap hashicorps "terraform" in a ruby DSL for managing stack templates'
  spec.description = 'Cloudshaper provides a syntax for managing terraform infrastructure entirely in git'
  spec.authors     = ['Dale Hamel']
  spec.email       = 'dale.hamel@srvthe.net'
  spec.files       = Dir['lib/**/*']
  spec.homepage    = 'https://github.com/dalehamel/cloudshaper'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rake', '~> 10.4'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '~> 5.6'
end
