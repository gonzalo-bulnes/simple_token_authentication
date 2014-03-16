# See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/26
Feature: Smoke test
  As a developer
  In order to make sure Rails Engine Decorators is correctly configured
  I want to run a smoke test

  # uncomment to see details (including the files tree)
  #@announce
  @rspec
  Scenario: Decorating a controller from the application (without Rails Engine Decorators)
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `sign_in` methods always raise an exception
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` User
    And I append to "app/controllers/private_posts_controller.rb" with:
      """

      PrivatePostsController.class_eval do
        # See https://github.com/atd/rails_engine_decorators/blob/\
        # 8384cb7f79e8673a10c1638b9ad64b0c7f1cdad1/test/rails_engine_decorators_test.rb
        def decorated?
          true
        end
      end
      """
    # `tree` is not available on Travis-ci
    # And I run `tree ./app`
    And I run `ls -R ./app`
    And I run `cat app/controllers/private_posts_controller.rb`
    And I write to "spec/requests/private_posts_controller_spec.rb" with:
      """
      require 'spec_helper'

      describe PrivatePostsController do
        it "is decorated" do
          expect(subject.decorated?).to eq true
        end
      end
      """
    And I silence the PrivatePostsController spec errors
    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      PrivatePostsController
        is decorated
      """

  # uncomment to see details (including the files tree)
  #@announce
  @rspec
  Scenario: Decorating a controller from the application (with Rails Engine Decorators)
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `sign_in` methods always raise an exception
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` User
    And a directory named "app/decorators/controllers/dummy"
    And I write to "app/decorators/controllers/dummy/private_posts_controller_decorator.rb" with:
      """
      PrivatePostsController.class_eval do
        # See https://github.com/atd/rails_engine_decorators/blob/\
        # 8384cb7f79e8673a10c1638b9ad64b0c7f1cdad1/test/rails_engine_decorators_test.rb
        def decorated?
          true
        end
      end
      """
    # `tree` is not available on Travis-ci
    # And I run `tree ./app`
    And I run `ls -R ./app`
    And I write to "spec/requests/private_posts_controller_spec.rb" with:
      """
      require 'spec_helper'

      describe PrivatePostsController do
        it "is not decorated and raises NoMethodError" do
          expect{ subject.decorated? }.to raise_exception NoMethodError
        end

        it "should be decorated" do
          pending "This example fails, but keeping it pending improves readability."
          expect(subject.decorated?).to eq true
        end
      end
      """
    And I silence the PrivatePostsController spec errors
    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should contain:
      """
      PrivatePostsController
      """
    And the output should contain:
      """
        should be decorated
      """
    And the output should contain:
      """
        is not decorated and raises NoMethodError
      """
