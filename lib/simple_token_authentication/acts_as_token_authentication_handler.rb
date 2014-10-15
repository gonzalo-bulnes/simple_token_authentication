require 'active_support'

require 'simple_token_authentication/entities_manager'
require 'simple_token_authentication/fallback_authentication_handler'
require 'simple_token_authentication/sign_in_handler'
require 'simple_token_authentication/token_authentication_handler'
require 'simple_token_authentication/token_comparator'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticationHandlerMethods
    extend ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :authenticate_entity_from_token!
      private :authenticate_entity_from_fallback!
      private :token_correct?
      private :perform_sign_in!
      private :token_comparator
      private :sign_in_handler
      private :entities_manager
      private :fallback_authentication_handler
      private :find_record_from_identifier

      # This is necessary to test which arguments were passed to sign_in
      # from authenticate_entity_from_token!
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/32
      ActionController::Base.send :include, Devise::Controllers::SignInOut if Rails.env.test?
    end

    def authenticate_entity_from_token!(entity)
      record = find_record_from_identifier(entity)

      if token_correct?(record, entity, token_comparator)
        perform_sign_in!(record, sign_in_handler)
      end
    end

    def authenticate_entity_from_fallback!(entity, fallback_authentication_handler)
      fallback_authentication_handler.authenticate_entity!(self, entity)
    end

    def token_correct?(record, entity, token_comparator)
      record && token_comparator.compare(record.authentication_token,
                                         entity.get_token_from_params_or_headers(self))
    end

    def perform_sign_in!(record, sign_in_handler)
      # Sign in using token should not be tracked by Devise trackable
      # See https://github.com/plataformatec/devise/issues/953
      env["devise.skip_trackable"] = true

      # Notice the store option defaults to false, so the record
      # identifier is not actually stored in the session and a token
      # is needed for every request. That behaviour can be configured
      # through the sign_in_token option.
      sign_in_handler.sign_in self, record, store: SimpleTokenAuthentication.sign_in_token
    end

    def find_record_from_identifier(entity)
      email = entity.get_identifier_from_params_or_headers(self).presence

      # Rails 3 and 4 finder methods are supported,
      # see https://github.com/ryanb/cancan/blob/1.6.10/lib/cancan/controller_resource.rb#L108-L111
      record = nil
      if entity.model.respond_to? "find_by"
        record = email && entity.model.find_by(email: email)
      elsif entity.model.respond_to? "find_by_email"
        record = email && entity.model.find_by_email(email)
      end
    end

    def token_comparator
      @@token_comparator ||= TokenComparator.new
    end

    def sign_in_handler
      @@sign_in_handler ||= SignInHandler.new
    end

    def fallback_authentication_handler
      @@fallback_authentication_handler ||= FallbackAuthenticationHandler.new
    end

    def entities_manager
      self.class.entities_manager
    end
  end

  module ActsAsTokenAuthenticationHandler

    # This module ensures that no TokenAuthenticationHandler behaviour
    # is added before the class actually `acts_as_token_authentication_handler_for`
    # some token authenticatable model.
    # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8#issuecomment-31707201

    def acts_as_token_authentication_handler_for(model, options = {})
      include SimpleTokenAuthentication::TokenAuthenticationHandler
      handle_token_authentication_for(model, options)

      include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods
    end

    def acts_as_token_authentication_handler
      ActiveSupport::Deprecation.warn "`acts_as_token_authentication_handler()` is deprecated and may be removed from future releases, use `acts_as_token_authentication_handler_for(User)` instead.", caller
      acts_as_token_authentication_handler_for User
    end
  end
end
