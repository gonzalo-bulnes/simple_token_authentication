require 'devise'
require 'simple_token_authentication/configuration'

module SimpleTokenAuthentication
  extend Configuration
end

Devise.add_module(
  :simple_token_authenticatable,
  route: :session,
  strategy: true,
  controller: :session,
  model: 'simple_token_authentication/model'
)
