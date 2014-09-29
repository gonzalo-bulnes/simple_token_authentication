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
      private :fallback_authentication_handler
      private :find_record_from_identifier

      private :entity_name_camelize
      private :entity_token_header_name
      private :entity_identifier_header_name
      private :entity_token_param_name
      private :entity_identifier_param_name
      private :get_token_from_params_or_headers
      private :get_identifier_from_params_or_headers

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
                                         get_token_from_params_or_headers(entity))
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
      email = get_identifier_from_params_or_headers(entity).presence

      # Rails 3 and 4 finder methods are supported,
      # see https://github.com/ryanb/cancan/blob/1.6.10/lib/cancan/controller_resource.rb#L108-L111
      record = nil
      if entity.respond_to? "find_by"
        record = email && entity.find_by(email: email)
      elsif entity.respond_to? "find_by_email"
        record = email && entity.find_by_email(email)
      end
    end

    def entity_name_camelize entity
      entity.name.singularize.camelize
    end

    # Private: Return the name of the header to watch for the token authentication param
    def entity_token_header_name entity
      if SimpleTokenAuthentication.header_names["#{entity.name_underscore}".to_sym].presence
        SimpleTokenAuthentication.header_names["#{entity.name_underscore}".to_sym][:authentication_token]
      else
        "X-#{entity_name_camelize(entity)}-Token"
      end
    end

    # Private: Return the name of the header to watch for the email param
    def entity_identifier_header_name entity
      if SimpleTokenAuthentication.header_names["#{entity.name_underscore}".to_sym].presence
        SimpleTokenAuthentication.header_names["#{entity.name_underscore}".to_sym][:email]
      else
        "X-#{entity_name_camelize(entity)}-Email"
      end
    end

    def entity_token_param_name entity
      "#{entity.name_underscore}_token".to_sym
    end

    def entity_identifier_param_name entity
      "#{entity.name_underscore}_email".to_sym
    end

    def get_token_from_params_or_headers entity
      # if the token is not present among params, get it from headers
      if token = params[entity_token_param_name(entity)].blank? && request.headers[entity_token_header_name(entity)]
        params[entity_token_param_name(entity)] = token
      end
      params[entity_token_param_name(entity)]
    end

    def get_identifier_from_params_or_headers entity
      # if the identifier (email) is not present among params, get it from headers
      if email = params[entity_identifier_param_name(entity)].blank? && request.headers[entity_identifier_header_name(entity)]
        params[entity_identifier_param_name(entity)] = email
      end
      params[entity_identifier_param_name(entity)]
    end

    def token_comparator
      @token_comparator ||= TokenComparator.new
    end

    def sign_in_handler
      @sign_in_handler ||= SignInHandler.new
    end

    def fallback_authentication_handler
      @fallback_authentication_handler ||= FallbackAuthenticationHandler.new
    end
  end

  module ActsAsTokenAuthenticationHandler
    extend ActiveSupport::Concern

    # I have insulated the methods into an additional module to avoid before_filters
    # to be applied by the `included` block before acts_as_token_authentication_handler_for was called.
    # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8#issuecomment-31707201

    included do
      # nop
    end

    module ClassMethods
      def acts_as_token_authentication_handler_for(model, options = {})
        entity = Entity.new(model)

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
          def authenticate_#{entity.name_underscore}_from_token
            authenticate_entity_from_token!(#{entity_name(entity)})
          end

          def authenticate_#{entity.name_underscore}_from_token!
            authenticate_entity_from_token!(#{entity_name(entity)})
            authenticate_entity_from_fallback!(#{entity_name(entity)}, fallback_authentication_handler)
          end
        METHODS
      end

      private

      def entity_name entity
        entity.name
      end
    end
  end
end
ActionController::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
