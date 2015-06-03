module SimpleTokenAuthentication
  class DeviseFallbackHandler

    # Fallback to the Devise authentication strategies.
    def fallback!(controller, entity)
      authenticate_entity!(controller, entity)
    end

    # Devise authentication is performed through a controller
    # which includes Devise::Controllers::Helpers
    # See http://rdoc.info/github/plataformatec/devise/master/\
    #            Devise/Controllers/Helpers#define_helpers-class_method
    def authenticate_entity!(controller, entity)
      controller.send("authenticate_#{entity.name_underscore}!".to_sym)
    end
  end
end
