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
  s.license     = "GPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "activerecord", ">= 3.2.6", "< 5"
  s.add_dependency "actionmailer", ">= 3.2.6", "< 5"
  s.add_dependency "devise", "~> 3.2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails", "~> 4.3"
  s.add_development_dependency "cucumber-rails", "~> 1.4"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "aruba"
end
