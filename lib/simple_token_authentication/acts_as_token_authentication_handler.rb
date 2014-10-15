require 'active_support/deprecation'
require 'simple_token_authentication/token_authentication_handler'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticationHandler

    # This module ensures that no TokenAuthenticationHandler behaviour
    # is added before the class actually `acts_as_token_authentication_handler_for`
    # some token authenticatable model.
    # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8#issuecomment-31707201

    def acts_as_token_authentication_handler_for(model, options = {})
      include SimpleTokenAuthentication::TokenAuthenticationHandler
      handle_token_authentication_for(model, options)
    end

    def acts_as_token_authentication_handler
      ::ActiveSupport::Deprecation.warn "`acts_as_token_authentication_handler()` is deprecated and may be removed from future releases, use `acts_as_token_authentication_handler_for(User)` instead.", caller
      acts_as_token_authentication_handler_for User
    end
  end
end
