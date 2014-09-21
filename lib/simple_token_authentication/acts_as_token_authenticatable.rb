module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable
    extend ::ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :generate_authentication_token
      private :token_suitable?
      private :generate_token
    end

    def ensure_authentication_token
      if authentication_token.blank?
        self.authentication_token = generate_authentication_token
      end
    end

    def generate_authentication_token
      loop do
        token = generate_token
        break token if token_suitable?(token)
      end
    end

    def generate_token
      Devise.friendly_token
    end

    def token_suitable?(token)
      not self.class.exists?(authentication_token: token)
    end

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        before_save :ensure_authentication_token
      end
    end
  end
end
ActiveRecord::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
