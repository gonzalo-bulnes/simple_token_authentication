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
    end

    # Set an authentication token if missing
    #
    # Because it is intended to be used as a filter,
    # this method is -and should be kept- idempotent.
    def ensure_authentication_token
      token_fields.each do |field_name|
        if self.send(field_name).blank?
          self.send("#{field_name}=", generate_authentication_token(token_generator, field_name))
        end
      end
    end

    def generate_authentication_token(token_generator, field_name)
      loop do
        token = token_generator.generate_token
        break token if token_suitable?(token, field_name)
      end
    end

    def token_suitable?(token, field_name)
      self.class.where("#{field_name} = ?", token).blank?
    end

    def token_generator
      TokenGenerator.instance
    end

    def token_providers
      if SimpleTokenAuthentication.use_multiple_providers
        SimpleTokenAuthentication.token_providers[class_name_as_key].try(:keys) || []
      else
        []
      end
    end

    def use_token_providers?
      token_providers.present?
    end

    def token_fields
      if use_token_providers?
        SimpleTokenAuthentication.token_providers[class_name_as_key].values.uniq
      else
        [default_token_field]
      end
    end

    def token_for_provider(provider)
      if use_token_providers? && SimpleTokenAuthentication.token_providers[class_name_as_key][provider].present?
        self.send(SimpleTokenAuthentication.token_providers[class_name_as_key][provider])
      else
        self.send(default_token_field)
      end
    end

    def default_token_field
      'authentication_token'
    end

    def class_name_as_key
      self.class.name.underscore.to_sym
    end

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        before_save :ensure_authentication_token
      end
    end
  end
end
