require 'active_support/concern'
require 'simple_token_authentication/token_authenticatable'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable

    extend ActiveSupport::Concern

    # This module ensures that no TokenAuthenticatableHandler behaviour
    # is added before the class actually `acts_as_token_authenticatable`
    # otherwise we inject unnecessary methods into ORMs.
    # This follows the pattern of ActsAsTokenAuthenticationHandler

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        include SimpleTokenAuthentication::TokenAuthenticatable
      end
    end
  end
end
