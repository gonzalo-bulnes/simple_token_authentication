$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simple_token_authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simple_token_authentication"
  s.version     = SimpleTokenAuthentication::VERSION
  s.authors     = ["Gonzalo Bulnes Guilpain"]
  s.email       = ["gon.bulnes@gmail.com"]
  s.homepage    = "https://github.com/gonzalo-bulnes/simple_token_authentication"
  s.summary     = "Simple (but safe) token authentication for Rails apps or API with Devise."
  s.license     = "GPL-3.0+"

  s.files = Dir["{app,config,doc,lib}/**/*", "CHANGELOG.md", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*", "gemfiles/*.gemfile", "Appraisals"]

  s.add_dependency "actionmailer", ">= 3.2.6", "< 5"
  s.add_dependency "actionpack", ">= 3.2.6", "< 5"
  s.add_dependency "devise", "~> 3.2"

  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "inch", "~> 0.4"
  s.add_development_dependency "activerecord", ">= 3.2.6", "< 5"
  s.add_development_dependency 'mongoid', '>= 3.1.0', '< 5'
  s.add_development_dependency "appraisal", "~> 2.0"
end
