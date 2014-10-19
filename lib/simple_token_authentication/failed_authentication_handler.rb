module SimpleTokenAuthentication
  class FailedAuthenticationHandler
    # throw an authentication error
    # see https://github.com/hassox/warden/wiki/Failures#failing-authentication
    def authenticate_entity!(controller, entity)
      # FIXME the failure app is missing, in this case, the failure app may return 401 Unauthorized (?)
      # see https://github.com/plataformatec/devise/blob/v3.4.0/lib/devise/failure_app.rb
      throw(:warden, scope: entity.name_underscore.to_sym)
    end
  end
end
