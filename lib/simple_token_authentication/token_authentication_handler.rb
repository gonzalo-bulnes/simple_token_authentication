require 'active_support/concern'
require 'devise'

require 'simple_token_authentication/entities_manager'
require 'simple_token_authentication/devise_fallback_handler'
require 'simple_token_authentication/exception_fallback_handler'
require 'simple_token_authentication/sign_in_handler'
require 'simple_token_authentication/token_comparator'

module SimpleTokenAuthentication
  module TokenAuthenticationHandler
    extend ::ActiveSupport::Concern

    included do
      private_class_method :define_token_authentication_helpers_for
      private_class_method :set_token_authentication_hooks
      private_class_method :entities_manager
      private_class_method :fallback_handler

      private :authenticate_entity_from_token!
      private :fallback!
      private :token_correct?
      private :perform_sign_in!
      private :token_comparator
      private :sign_in_handler
      private :find_record_from_identifier
      private :integrate_with_devise_case_insensitive_keys
    end

    def authenticate_entity_from_token!(entity)
      record = find_record_from_identifier(entity)

      if token_correct?(record, entity, token_comparator)
        perform_sign_in!(record, sign_in_handler)
        after_successful_token_authentication if respond_to?(:after_successful_token_authentication)
      end
    end

    def fallback!(entity, fallback_handler)
      fallback_handler.fallback!(self, entity)
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
      identifier_param_value = entity.get_identifier_from_params_or_headers(self).presence

      identifier_param_value = integrate_with_devise_case_insensitive_keys(identifier_param_value, entity)

      # The finder method should be compatible with all the model adapters,
      # namely ActiveRecord and Mongoid in all their supported versions.
      identifier_param_value && entity.model.find_for_authentication(entity.identifier => identifier_param_value)
    end

    # Private: Take benefit from Devise case-insensitive keys
    #
    # See https://github.com/plataformatec/devise/blob/v3.4.1/lib/generators/templates/devise.rb#L45-L48
    #
    # identifier_value - the original identifier_value String
    #
    # Returns an identifier String value which case follows the Devise case-insensitive keys policy
    def integrate_with_devise_case_insensitive_keys(identifier_value, entity)
      identifier_value.downcase! if identifier_value && Devise.case_insensitive_keys.include?(entity.identifier)
      identifier_value
    end

    def token_comparator
      TokenComparator.instance
    end

    def sign_in_handler
      SignInHandler.instance
    end

    module ClassMethods

      # Provide token authentication handling for a token authenticatable class
      #
      # model - the token authenticatable Class
      #
      # Returns nothing.
      def handle_token_authentication_for(model, options = {})
        model_alias = options[:as] || options['as']
        entity = entities_manager.find_or_create_entity(model, model_alias)
        options = SimpleTokenAuthentication.parse_options(options)
        define_token_authentication_helpers_for(entity, fallback_handler(options))
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
      def fallback_handler(options)
        if class_variable_defined?(:@@fallback_authentication_handler)
          class_variable_get(:@@fallback_authentication_handler)
        else
          if options[:fallback] == :exception
            class_variable_set(:@@fallback_authentication_handler, ExceptionFallbackHandler.instance)
          else
            class_variable_set(:@@fallback_authentication_handler, DeviseFallbackHandler.instance)
          end
        end
      end

      def define_token_authentication_helpers_for(entity, fallback_handler)

        method_name = "authenticate_#{entity.name_underscore}_from_token"
        method_name_bang = method_name + '!'

        class_eval do
          define_method method_name.to_sym do
            lambda { |_entity| authenticate_entity_from_token!(_entity) }.call(entity)
          end

          define_method method_name_bang.to_sym do
            lambda do |_entity|
              authenticate_entity_from_token!(_entity)
              fallback!(_entity, fallback_handler)
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

        if respond_to?(:before_action)
          # See https://github.com/rails/rails/commit/9d62e04838f01f5589fa50b0baa480d60c815e2c
          before_action authenticate_method, options.slice(:only, :except, :if, :unless)
        else
          before_filter authenticate_method, options.slice(:only, :except, :if, :unless)
        end
      end
    end
  end
end
