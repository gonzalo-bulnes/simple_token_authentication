require 'devise/controllers/sign_in_out'

module SimpleTokenAuthentication
  class SignInHandler
    # Devise sign in is performed through a controller
    # which includes Devise::Controllers::SignInOut
    def sign_in(controller, record, *args)
      controller.send(:sign_in, record, *args)
    end
  end
end
