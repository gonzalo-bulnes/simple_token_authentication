require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class SimpleTokenAuthentication < Authenticatable

      def valid?
        auth_key.present?
      end

      def authenticate!
        resource = mapping.to.find_for_authentication(login_with => auth_key)

        if resource && validate(resource) { Devise.secure_compare(resource.authentication_token, token) }
          success!(resource)
        else
          return fail(:invalid)
        end

      end

      private

      def snake_resource_name
        mapping.to.name.underscore
      end

      def login_with
        'email'
      end

      # Pass in auth key as resource_name_key e.g. user_email or 
      def auth_key
        params["#{snake_resource_name}_#{login_with}"] || lookup_header
      end

      def token
        params["#{snake_resource_name}_token"] || token_header
      end

      def configured_headings
        ::Devise.token_header_names[snake_resource_name.to_sym]
      end

      def token_header
        configured_key = configured_headings[:authentication_token]
        token_key = configured_key.presence ? configured_key : "X-#{mapping.to.name}-Token"
        request.headers[token_key]
      end

      def lookup_header
        configured_key = configured_headings[login_with.to_sym]
        lookup_key = configured_key.presence ? configured_key : "X-#{mapping.to.name}-#{login_with.camelize}"
        request.headers[lookup_key]
      end
    end
  end
end

Warden::Strategies.add(:simple_token_authenticatable, Devise::Strategies::SimpleTokenAuthentication)
