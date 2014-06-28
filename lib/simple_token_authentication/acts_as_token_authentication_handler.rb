module SimpleTokenAuthentication
  module ActsAsTokenAuthenticationHandler
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_token_authentication_handler_for(entity, options = {})
        ActiveSupport::Deprecation.warn "`acts_as_token_authentication_handler_for()` is deprecated and may be removed from future releases.", caller
        ActiveSupport::Deprecation.warn "`:fallback_to_devise` option is no longer supported.", caller if options[:fallback_to_devise]
        before_filter :"authenticate_#{entity.name.singularize.underscore}!",
                      options.slice(:only, :except)
      end
    end
  end
end
ActionController::Base.send :include, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler
