# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/32
Feature: The sign_in_token option can be configured via an initializer
  As a developer
  In order to allow the authentication token to act as a sign in token
  I want an the sign_in_token option to be available and configurable

  @rspec
  Scenario: Without intializer, the user is not stored in the session after authentication
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` method always raises an exception
    And the `sign_in` method always raises an exception to show its arguments
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` User
    And I write to "spec/factories/users.rb" with:
      """
      FactoryGirl.define do
        sequence :email do |n|
          "user#{n}@factory.com"
        end

        factory :user do
          email
          password  "password"
          password_confirmation "password"
        end
      end
      """
    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "when authentication is successful" do

            let(:user) do
              FactoryGirl.create(:user \
                                 ,email: 'alice@example.com' \
                                 ,authentication_token: 'ExaMpLeTokEn')
            end

            it "does not store the user in the session by default" do
              # `sign_in` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda do
                get private_posts_path, { user_email: user.email, user_token: user.authentication_token}
              end.should raise_exception(RuntimeError, "`sign_in` was called with options `{:store=>false}`.")
            end
          end
        end
      end
      """

    And I silence the PrivatePostsController spec errors

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      PrivatePosts
        GET /private_posts
          when authentication is successful
            does not store the user in the session by default
      """

  @rspec
  Scenario: Override the sign_in_token option value with an initalizer
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` method always raises an exception
    And the `sign_in` method always raises an exception to show its arguments
    And I write to "config/initializers/simple_token_authentication.rb" with:
      """
      SimpleTokenAuthentication.configure do |config|

        # Configure the session persistence policy after a successful sign in,
        # in other words, if the authentication token acts as a signin token.
        # If true, user is stored in the session and the authentication token and
        # email may be provided only once.
        # If false, users must provide their authentication token and email at every request.
        # config.sign_in_token = false
        config.sign_in_token = true
      end
      """
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` User
    And I write to "spec/factories/users.rb" with:
      """
      FactoryGirl.define do
        sequence :email do |n|
          "user#{n}@factory.com"
        end

        factory :user do
          email
          password  "password"
          password_confirmation "password"
        end
      end
      """
    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "when an initializer overrides the sign_in_token default value" do

            # See config/initializers/simple_token_authentication.rb

            context "and authentication is successful" do

              let(:user) do
                FactoryGirl.create(:user \
                                   ,email: 'alice@example.com' \
                                   ,authentication_token: 'ExaMpLeTokEn' )
              end

              it "stores the user in the session" do
                # `sign_in` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda do
                  get private_posts_path, { user_email: user.email, user_token: user.authentication_token }
                end.should raise_exception(RuntimeError, "`sign_in` was called with options `{:store=>true}`.")
              end
            end
          end
        end
      end
      """

    And I silence the PrivatePostsController spec errors

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      PrivatePosts
        GET /private_posts
          when an initializer overrides the sign_in_token default value
            and authentication is successful
              stores the user in the session
      """
