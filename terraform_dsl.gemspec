Gem::Specification.new do |s|
  s.name        = 'terraform_dsl'
  s.version     = '0.0.4'
  s.date        = '2015-06-01'
  s.summary     = 'Wrap hashicorps "terraform" in a ruby DSL for managing stack templates'
  s.description = 'Terraform DSL provides a syntax for managing terraform infrastructure entirely in git'
  s.authors     = ['Dale Hamel']
  s.email       = 'dale.hamel@srvthe.net'
  s.files       = Dir['lib/**/*']
  s.homepage    = 'https://rubygems.org/gems/terraform_dsl'
  s.license       = 'MIT'

  s.add_runtime_dependency 'rake', '~> 10.4'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest', '~> 5.6'
end
