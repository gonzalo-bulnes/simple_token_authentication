require 'active_support/concern'
require 'simple_token_authentication/token_generator'

module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable
    extend ::ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :generate_authentication_token
      private :token_suitable?
      private :token_generator
      private :persist_token_as_plain?
      private :persist_token_as_digest?

      attr_accessor :plain_authentication_token, :persisted_authentication_token
    end

    def authentication_token= token

      self.plain_authentication_token = token

      if persist_token_as_plain?
        # Persist the plain token
        self.persisted_authentication_token = token
      elsif persist_token_as_digest?
        # Persist the digest of the token
        self.persisted_authentication_token = Devise::Encryptor.digest(SimpleTokenAuthentication, token)
      end

      # Check for existence of an overridden method, to allow specs to operate without a true persistence layer
      if defined?(super)
        super(self.persisted_authentication_token)
      end
    end

    def authentication_token
      self.plain_authentication_token
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
      return true if persist_token_as_digest?
      self.class.where(authentication_token: token).count == 0
    end

    def token_generator
      TokenGenerator.instance
    end


    def persist_token_as_plain?
      SimpleTokenAuthentication.persist_token_as == :plain
    end

    def persist_token_as_digest?
      SimpleTokenAuthentication.persist_token_as == :digest
    end


    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        before_save :ensure_authentication_token
      end
    end
  end
end
