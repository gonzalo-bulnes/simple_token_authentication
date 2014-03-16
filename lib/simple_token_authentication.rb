# See https://github.com/atd/rails_engine_decorators/issues/6#issuecomment-37773030
require 'rails_engine_decorators'

require 'simple_token_authentication/engine'
require 'simple_token_authentication/acts_as_token_authenticatable'
require 'simple_token_authentication/acts_as_token_authentication_handler'
require 'simple_token_authentication/configuration'

module SimpleTokenAuthentication
  extend Configuration
end
