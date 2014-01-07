class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # While `acts_as_token_authentication_handler` was not called,
  # neither should be `authenticate_user!`.
  # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8
  #
  # Yet once `acts_as_token_authentication_handler` was called, `authenticate_user!`
  # should also be called. Run `rspec` to ensure that's being true.
  # If called, the `authenticate_user!` method will raise an exception, that
  # allows both cases to be covered by their own spec example.
  #
  # See test/dummy/app/controllers/posts_controller.rb and
  # test/dummy/app/controllers/private_posts_controller.rb

  def authenticate_user!
    raise "`authenticate_user!` was called."
  end
end
