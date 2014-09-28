module SimpleTokenAuthentication
  module ActsAsTokenAuthenticationHandlerMethods
    extend ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :authenticate_entity_from_token!
      private :entity_name_camelize
      private :entity_name_underscore
      private :entity_token_header_name
      private :entity_identifier_header_name
      private :entity_token_param_name
      private :entity_identifier_param_name
      private :get_token_from_params_or_headers

      # This is necessary to test which arguments were passed to sign_in
      # from authenticate_entity_from_token!
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/32
      ActionController::Base.send :include, Devise::Controllers::SignInOut if Rails.env.test?
    end

    def authenticate_entity!(entity_class)
      # Caution: entity should be a singular camel-cased name but could be pluralized or underscored.
      self.method("authenticate_#{entity_name_underscore(entity_class)}!".to_sym).call
    end

    def authenticate_entity_from_token!(entity_class)
      # Set the authentication token params if not already present,
      # see http://stackoverflow.com/questions/11017348/rails-api-authentication-by-headers-token
      if email = params[entity_identifier_param_name(entity_class)].blank? && request.headers[entity_identifier_header_name(entity_class)]
        params[entity_identifier_param_name(entity_class)] = email
      end

      email = params[entity_identifier_param_name(entity_class)].presence
      # See https://github.com/ryanb/cancan/blob/1.6.10/lib/cancan/controller_resource.rb#L108-L111
      entity = nil
      if entity_class.respond_to? "find_by"
        entity = email && entity_class.find_by(email: email)
      elsif entity_class.respond_to? "find_by_email"
        entity = email && entity_class.find_by_email(email)
      end

      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      if entity && Devise.secure_compare(entity.authentication_token, get_token_from_params_or_headers(entity_class))
        # Sign in using token should not be tracked by Devise trackable
        # See https://github.com/plataformatec/devise/issues/953
        env["devise.skip_trackable"] = true

        # Notice the store option defaults to false, so the entity
        # is not actually stored in the session and a token is needed
        # for every request. That behaviour can be configured through
        # the sign_in_token option.
        sign_in entity, store: SimpleTokenAuthentication.sign_in_token
      end
    end

    def entity_name_camelize entity
      entity.name.singularize.camelize
    end

    def entity_name_underscore entity
      entity.name.singularize.underscore
    end

    # Private: Return the name of the header to watch for the token authentication param
    def entity_token_header_name entity
      if SimpleTokenAuthentication.header_names["#{entity_name_underscore(entity)}".to_sym].presence
        SimpleTokenAuthentication.header_names["#{entity_name_underscore(entity)}".to_sym][:authentication_token]
      else
        "X-#{entity_name_camelize(entity)}-Token"
      end
    end

    # Private: Return the name of the header to watch for the email param
    def entity_identifier_header_name entity
      if SimpleTokenAuthentication.header_names["#{entity_name_underscore(entity)}".to_sym].presence
        SimpleTokenAuthentication.header_names["#{entity_name_underscore(entity)}".to_sym][:email]
      else
        "X-#{entity_name_camelize(entity)}-Email"
      end
    end

    def entity_token_param_name entity
      "#{entity_name_underscore(entity)}_token".to_sym
    end

    def entity_identifier_param_name entity
      "#{entity_name_underscore(entity)}_email".to_sym
    end

    def get_token_from_params_or_headers entity
      # if the token is not present among params, get it from headers
      if token = params[entity_token_param_name(entity)].blank? && request.headers[entity_token_header_name(entity)]
        params[entity_token_param_name(entity)] = token
      end
      params[entity_token_param_name(entity)]
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
      def acts_as_token_authentication_handler_for(entity, options = {})
        options = { fallback_to_devise: true }.merge(options)

        include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods

        define_acts_as_token_authentication_helpers_for(entity)

        authenticate_method = if options[:fallback_to_devise]
          :"authenticate_#{entity_name_underscore(entity)}_from_token!"
        else
          :"authenticate_#{entity_name_underscore(entity)}_from_token"
        end
        before_filter authenticate_method, options.slice(:only, :except)
      end

      def acts_as_token_authentication_handler
        ActiveSupport::Deprecation.warn "`acts_as_token_authentication_handler()` is deprecated and may be removed from future releases, use `acts_as_token_authentication_handler_for(User)` instead.", caller
        acts_as_token_authentication_handler_for User
      end

      def define_acts_as_token_authentication_helpers_for(entity_class)
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def authenticate_#{entity_name_underscore(entity_class)}_from_token
            authenticate_entity_from_token!(#{entity_name(entity_class)})
          end

          def authenticate_#{entity_name_underscore(entity_class)}_from_token!
            authenticate_entity_from_token!(#{entity_name(entity_class)})
            authenticate_entity!(#{entity_name(entity_class)})
          end
        METHODS
      end

      private

      def entity_name entity
        entity.name
      end

      def entity_name_underscore entity
        entity.name.singularize.underscore
      end
    end
  end
end
ActionController::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
