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

    def authenticate_entity_from_token!(entity, search_options)
      identifier, token = search_parameters(search_options)
      record = find_record_from_identifier(entity, identifier)

      if token_correct?(record, token, token_comparator)
        perform_sign_in!(record, sign_in_handler)
      end
    end

    def fallback!(entity, fallback_handler)
      fallback_handler.fallback!(self, entity)
    end

    def token_correct?(record, token, token_comparator)
      record && token_comparator.compare(record.authentication_token, token)
    end

    def perform_sign_in!(record, sign_in_handler)
      # Notice the store option defaults to false, so the record
      # identifier is not actually stored in the session and a token
      # is needed for every request. That behaviour can be configured
      # through the sign_in_token option.
      sign_in_handler.sign_in self, record, store: SimpleTokenAuthentication.sign_in_token
    end

    def search_parameters(search_options)
      if search_options[:headers]
        parameters = retrieve_parameters(request.headers, search_options[:headers][:identifier],
                                         search_options[:headers][:token])
        return parameters if parameters
      end
      if search_options[:params]
        retrieve_parameters(params, search_options[:params][:identifier],
                            search_options[:params][:token])
      end
    end

    def retrieve_parameters(object, identifier, token)
      if object[identifier].present? && object[token].present?
        [object[identifier], object[token]]
      else
        nil
      end
    end

    def find_record_from_identifier(entity, identifier)
      identifier = integrate_with_devise_case_insensitive_keys(identifier, entity)

      # The finder method should be compatible with all the model adapters,
      # namely ActiveRecord and Mongoid in all their supported versions.
      identifier && entity.model.find_for_authentication(entity.identifier => identifier)
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
        define_token_authentication_helpers_for(entity, search_options(entity, options),
                                                fallback_handler(options))
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

      # Private: Gets the options for finding the identifier and token for the current controller.
      def search_options(entity, options)
        default_options = {
          params: {
            identifier: "#{entity.name_underscore}_#{entity.identifier}".to_sym,
            token: "#{entity.name_underscore}_token".to_sym,
          },
          headers: {
            identifier: "X-#{entity.name_underscore.camelize}-#{entity.identifier.to_s.camelize}",
            token: "X-#{entity.name_underscore.camelize}-Token"
          }
        }
        default_options.deep_merge(options[:search] || {})
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

      def define_token_authentication_helpers_for(entity, search_options, fallback_handler)

        method_name = "authenticate_#{entity.name_underscore}_from_token"
        method_name_bang = method_name + '!'

        class_eval do
          define_method method_name.to_sym do
            authenticate_entity_from_token!(entity, search_options)
          end

          define_method method_name_bang.to_sym do
            authenticate_entity_from_token!(entity, search_options)
            fallback!(entity, fallback_handler)
          end
        end
      end

      def set_token_authentication_hooks(entity, options)
        authenticate_method = unless options[:fallback] == :none
          :"authenticate_#{entity.name_underscore}_from_token!"
        else
          :"authenticate_#{entity.name_underscore}_from_token"
        end
        before_filter authenticate_method, options.slice(:only, :except, :if, :unless)
      end
    end
  end
end
