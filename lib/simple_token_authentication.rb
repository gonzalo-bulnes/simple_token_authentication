require 'devise'

require 'simple_token_authentication/model'
require 'simple_token_authentication/acts_as_token_authentication_handler'

module Devise
  mattr_accessor :token_header_names
  @@header_names = {}

  mattr_accessor :sign_in_token
  @@sign_in_token = false
end

Devise.add_module(
  :simple_token_authentication,
  route: :session,
  strategy: true,
  controller: :session,
  model: 'simple_token_authentication/model'
)