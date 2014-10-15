require 'active_support'
require 'simple_token_authentication/entities_manager'

module SimpleTokenAuthentication
  module TokenAuthenticationHandler
    extend ActiveSupport::Concern

    included do
      private_class_method :define_token_authentication_helpers_for
      private_class_method :set_token_authentication_hooks
    end

    module ClassMethods

      # Provide token authentication handling for a token authenticatable class
      #
      # model - the token authenticatable Class
      #
      # Returns nothing.
      def handle_token_authentication_for(model, options = {})
        entity = entities_manager.find_or_create_entity(model)
        define_token_authentication_helpers_for(entity)
        set_token_authentication_hooks(entity, options)
      end

      def entities_manager
        entities_manager ||= EntitiesManager.new
        class_variable_set :@@entities_manager, entities_manager
      end

      def define_token_authentication_helpers_for(entity)
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          # Get an Entity instance by its name
          def get_entity(name)
            entities_manager.find_or_create_entity(name.constantize)
          end

          def authenticate_#{entity.name_underscore}_from_token
            authenticate_entity_from_token!(get_entity('#{entity.name}'))
          end

          def authenticate_#{entity.name_underscore}_from_token!
            authenticate_entity_from_token!(get_entity('#{entity.name}'))
            authenticate_entity_from_fallback!(get_entity('#{entity.name}'), fallback_authentication_handler)
          end
        METHODS
      end

      def set_token_authentication_hooks(entity, options)
        options = { fallback_to_devise: true }.merge(options)

        authenticate_method = if options[:fallback_to_devise]
          :"authenticate_#{entity.name_underscore}_from_token!"
        else
          :"authenticate_#{entity.name_underscore}_from_token"
        end
        before_filter authenticate_method, options.slice(:only, :except)
      end
    end
  end
end
