module SimpleTokenAuthentication
  class ExceptionFallbackHandler
    include Singleton

    # Notifies the failure of authentication to Warden in the same DEvise does.
    # Does result in an HTTP 401 response in a Devise context.
    def fallback!(controller, entity)
      throw(:warden, scope: entity.name_underscore.to_sym) if controller.send("current_#{entity.name_underscore}").nil?
    end
  end
end
