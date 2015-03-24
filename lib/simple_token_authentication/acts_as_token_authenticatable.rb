require 'simple_token_authentication/token_authenticatable'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable

    # This module ensures that no TokenAuthenticatable behaviour
    # is added before the class actually `acts_as_token_authenticatable`.

    def acts_as_token_authenticatable(options = {})
      include SimpleTokenAuthentication::TokenAuthenticatable
      before_save :ensure_authentication_token
    end
  end
end
