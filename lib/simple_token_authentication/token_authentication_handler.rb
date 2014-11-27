require 'active_support/concern'

require 'simple_token_authentication/entities_manager'
require 'simple_token_authentication/fallback_authentication_handler'
require 'simple_token_authentication/sign_in_handler'
require 'simple_token_authentication/token_comparator'

module SimpleTokenAuthentication
  module TokenAuthenticationHandler
    extend ::ActiveSupport::Concern

    included do
      private_class_method :define_token_authentication_helpers_for
      private_class_method :set_token_authentication_hooks
      private_class_method :entities_manager
      private_class_method :fallback_authentication_handler

      private :authenticate_entity_from_token!
      private :authenticate_entity_from_fallback!
      private :token_correct?
      private :perform_sign_in!
      private :token_comparator
      private :sign_in_handler
      private :find_record_from_identifier
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
      # Notice the store option defaults to false, so the record
      # identifier is not actually stored in the session and a token
      # is needed for every request. That behaviour can be configured
      # through the sign_in_token option.
      sign_in_handler.sign_in self, record, store: SimpleTokenAuthentication.sign_in_token
    end

    def find_record_from_identifier(entity)
      email = entity.get_identifier_from_params_or_headers(self).presence

      # The finder method should be compatible with all the model adapters,
      # namely ActiveRecord and Mongoid in all their supported versions.
      record = nil
      record = email && entity.model.where(email: email).first
    end

    # Private: Get one (always the same) object which behaves as a token comprator
    def token_comparator
      @@token_comparator ||= TokenComparator.new
    end

    # Private: Get one (always the same) object which behaves as a sign in handler
    def sign_in_handler
      @@sign_in_handler ||= SignInHandler.new
    end

    module ClassMethods

      # Provide token authentication handling for a token authenticatable class
      #
      # model - the token authenticatable Class
      #
      # Returns nothing.
      def handle_token_authentication_for(model, options = {})
        entity = entities_manager.find_or_create_entity(model)
        options = SimpleTokenAuthentication.parse_options(options)
        define_token_authentication_helpers_for(entity, fallback_authentication_handler)
        set_token_authentication_hooks(entity, options)
      end

      # Private: Get one (always the same) object which behaves as an entities manager
      def entities_manager
        if class_variable_defined?(:@@entities_manager)
          class_variable_get(:@@entities_manager)
        else
          class_variable_set(:@@entities_manager, EntitiesManager.new)
        end
      end

      # Private: Get one (always the same) object which behaves as a fallback authentication handler
      def fallback_authentication_handler
        if class_variable_defined?(:@@fallback_authentication_handler)
          class_variable_get(:@@fallback_authentication_handler)
        else
          class_variable_set(:@@fallback_authentication_handler, FallbackAuthenticationHandler.new)
        end
      end

      def define_token_authentication_helpers_for(entity, fallback_authentication_handler)

        method_name = "authenticate_#{entity.name_underscore}_from_token"
        method_name_bang = method_name + '!'

        class_eval do
          define_method method_name.to_sym do
            lambda { |_entity| authenticate_entity_from_token!(_entity) }.call(entity)
          end

          define_method method_name_bang.to_sym do
            lambda do |_entity|
              authenticate_entity_from_token!(_entity)
              authenticate_entity_from_fallback!(_entity, fallback_authentication_handler)
            end.call(entity)
          end
        end
      end

      def set_token_authentication_hooks(entity, options)
        authenticate_method = unless options[:fallback] == :none
          :"authenticate_#{entity.name_underscore}_from_token!"
        else
          :"authenticate_#{entity.name_underscore}_from_token"
        end
        before_filter authenticate_method, options.slice(:only, :except)
      end
    end
  end
end
