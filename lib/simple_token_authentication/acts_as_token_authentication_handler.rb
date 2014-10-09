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
    extend ActiveSupport::Concern

    # I have insulated the methods into an additional module to avoid before_filters
    # to be applied by the `included` block before acts_as_token_authentication_handler_for was called.
    # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8#issuecomment-31707201

    included do
      private_class_method :define_acts_as_token_authentication_helpers_for
    end

    module ClassMethods
      def acts_as_token_authentication_handler_for(model, options = {})
        entity = entities_manager.find_or_create_entity(model)

        options = { fallback_to_devise: true }.merge(options)

        include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods

        define_acts_as_token_authentication_helpers_for(entity)

        authenticate_method = if options[:fallback_to_devise]
          :"authenticate_#{entity.name_underscore}_from_token!"
        else
          :"authenticate_#{entity.name_underscore}_from_token"
        end
        before_filter authenticate_method, options.slice(:only, :except)
      end

      def acts_as_token_authentication_handler
        ActiveSupport::Deprecation.warn "`acts_as_token_authentication_handler()` is deprecated and may be removed from future releases, use `acts_as_token_authentication_handler_for(User)` instead.", caller
        acts_as_token_authentication_handler_for User
      end

      def define_acts_as_token_authentication_helpers_for(entity)

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

      def entities_manager
        entities_manager ||= EntitiesManager.new
        class_variable_set :@@entities_manager, entities_manager
      end
    end
  end
end
