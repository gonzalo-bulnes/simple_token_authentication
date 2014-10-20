require 'bundler/setup'
Bundler.setup

require 'action_controller'
require 'active_support'

require 'simple_token_authentication'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f; puts f }

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
