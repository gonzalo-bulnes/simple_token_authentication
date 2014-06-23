module SimpleTokenAuthentication
  module ActsAsTokenAuthenticatable
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_token_authenticatable(options = {})
        ActiveSupport::Deprecation.warn "`acts_as_token_authenticatable()` is deprecated and may be removed from future releases", caller
        devise :simple_token_authenticatable
      end
    end
  end
end
ActiveRecord::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticatable
