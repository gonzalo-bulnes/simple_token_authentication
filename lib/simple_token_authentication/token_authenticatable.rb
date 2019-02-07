require 'active_support/concern'
require 'simple_token_authentication/token_generator'

module SimpleTokenAuthentication
  module TokenAuthenticatable
    extend ::ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :generate_authentication_token
      private :token_suitable?
      private :token_generator
      private :invalidate_cached_auth

      before_save :ensure_authentication_token

      attr_accessor :plain_authentication_token, :persisted_authentication_token
    end

    def authentication_token= token

      self.plain_authentication_token = token

      if token.nil?
        self.persisted_authentication_token = nil
      elsif  SimpleTokenAuthentication.persist_token_as_plain?
        # Persist the plain token
        self.persisted_authentication_token = token
      elsif SimpleTokenAuthentication.persist_token_as_digest?
        # Persist the digest of the token
        self.persisted_authentication_token = Devise::Encryptor.digest(SimpleTokenAuthentication, token)
      end

      invalidate_cached_auth

      # Check for existence of an write_attribute method, to allow specs to operate without a true persistence layer
      if defined?(write_attribute)
        write_attribute(:authentication_token, self.persisted_authentication_token)
      end
    end

    def authentication_token
      if defined?(read_attribute)
        read_attribute :authentication_token
      else
        persisted_authentication_token
      end
    end

    # Set an authentication token if missing
    #
    # Because it is intended to be used as a filter,
    # this method is -and should be kept- idempotent.
    def ensure_authentication_token
      if authentication_token.blank?
        self.authentication_token = generate_authentication_token(token_generator)
      end
    end

    def generate_authentication_token(token_generator)
      loop do
        token = token_generator.generate_token
        break token if token_suitable?(token)
      end
    end

    def token_suitable?(token)
      # Alway true if digest is persisted, since we can't check for duplicates
      return true if SimpleTokenAuthentication.persist_token_as_digest?
      self.class.where(authentication_token: token).count == 0
    end

    def token_generator
      TokenGenerator.instance
    end

    # Invalidate an existing cache item
    def invalidate_cached_auth
      cache = SimpleTokenAuthentication.cache_provider
      cache.invalidate_auth(self.id) if cache
    end

  end
end
