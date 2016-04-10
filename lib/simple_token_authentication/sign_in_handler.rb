module SimpleTokenAuthentication
  class SignInHandler
    include Singleton

    # Devise sign in is performed through a controller
    # which includes Devise::Controllers::SignInOut
    def sign_in(controller, record, *args)
      integrate_with_devise_trackable!(controller)

      controller.send(:sign_in, record, *args)
    end

    private

    def integrate_with_devise_trackable!(controller)
      # Sign in using token should not be tracked by Devise trackable
      # See https://github.com/plataformatec/devise/issues/953
      controller.env["devise.skip_trackable"] = SimpleTokenAuthentication.skip_devise_trackable
    end
  end
end
