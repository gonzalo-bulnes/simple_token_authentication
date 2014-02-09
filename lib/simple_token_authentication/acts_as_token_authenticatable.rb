module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable
    extend ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :generate_authentication_token
    end

    def ensure_authentication_token
      if authentication_token.blank?
        self.authentication_token = generate_authentication_token
      end
    end

    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end

    def token_authentication_params
      {}.tap do |params|
        if self.respond_to?(:authentication_token) && self.authentication_token &&
          self.respond_to?(:email) && self.email
          params[:user_token] = authentication_token
          params[:user_email] = email
        end
      end
    end

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        include SimpleTokenAuthentication::ActsAsTokenAuthenticatable
        before_save :ensure_authentication_token
      end
    end
  end
end
ActiveRecord::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
