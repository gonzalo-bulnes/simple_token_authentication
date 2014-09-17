module SimpleTokenAuthentication
  module ActsAsTokenAuthenticationHandlerMethods
    extend ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :authenticate_entity_from_token!
      private :header_token_name
      private :header_email_name

      # This is necessary to test which arguments were passed to sign_in
      # from authenticate_entity_from_token!
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/32
      ActionController::Base.send :include, Devise::Controllers::SignInOut if Rails.env.test?
    end

    def authenticate_entity!(given_entity_class)
      @entity_class = given_entity_class
      self.method("authenticate_#{entity_class_string}!".to_sym).call
    end

    # For this example, we are simply using token authentication
    # via parameters. However, anyone could use Rails's token
    # authentication features to get the token from a header.
    def authenticate_entity_from_token!(given_entity_class)
      @entity_class = given_entity_class
      entity = class_finder_method(email)
      if entity && Devise.secure_compare(entity.authentication_token, token)
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

    private

    def entity_class
      @entity_class
    end

    def entity_class_string
      entity_class.name.singularize.underscore
    end

    def entitiy_class_sym
      entity_class_string.to_sym
    end

    def token
      params["#{entity_class_string}_token".to_sym] || request.headers[header_token_name]
    end

    def email
      params["#{entity_class_string}_email".to_sym] || request.headers[header_email_name]
    end

    def class_finder_method(email)
      case
      when entity_class.respond_to?("find_by")
        entity_class.find_by(email: email)
      when entity_class.respond_to?("find_by_email")
        entity_class.find_by_email(email)
      else
        nil
      end
    end

    # Private: Return the name of the header to watch for the token authentication param
    def header_token_name
      header_auth_hash.presence || "X-#{entity_class.name.singularize.camelize}-Token"
    end

    # Private: Return the name of the header to watch for the email param
    def header_email_name
      header_email_hash.presence || "X-#{entity_class.name.singularize.camelize}-Email"
    end

    def header_auth_hash
      header_names[:authentication_token] if header_names
    end

    def header_email_hash
      header_names[:email] if header_names
    end

    def header_names
      SimpleTokenAuthentication.header_names[entitiy_class_sym]
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
          :"authenticate_#{entity.name.singularize.underscore}_from_token!"
        else
          :"authenticate_#{entity.name.singularize.underscore}_from_token"
        end
        before_filter authenticate_method, options.slice(:only, :except)
      end

      def acts_as_token_authentication_handler
        ActiveSupport::Deprecation.warn "`acts_as_token_authentication_handler()` is deprecated and may be removed from future releases, use `acts_as_token_authentication_handler_for(User)` instead.", caller
        acts_as_token_authentication_handler_for User
      end

      def define_acts_as_token_authentication_helpers_for(given_entity_class)
        entity_underscored = given_entity_class.name.singularize.underscore

        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def authenticate_#{entity_underscored}_from_token
            authenticate_entity_from_token!(#{given_entity_class.name})
          end

          def authenticate_#{entity_underscored}_from_token!
            authenticate_entity_from_token!(#{given_entity_class.name})
            authenticate_entity!(#{given_entity_class.name})
          end
        METHODS
      end
    end
  end
end
ActionController::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
