require 'devise'

module SimpleTokenAuthentication
  class TokenGenerator
    include Singleton

    def generate_token
      Devise.friendly_token
    end
  end
end
