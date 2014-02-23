# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/33
Feature: The header_names option can be configured via an initializer
  As a developer
  In order to be able to use any HTTP headers that make sense for a given API
  I want an the header_names option to be available and configurable

  @rspec
  Scenario: Using default header names
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `sign_in` methods always raise an exception
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
    And I write to "spec/requests/private_posts_controller_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePostsController" do
        describe "GET /private_posts" do

          context "when the default headers are set in the request" do

            it "performs token authentication" do
              user = FactoryGirl.create(:user \
                                 ,email: 'alice@example.com' \
                                 ,authentication_token: 'ExaMpLeTokEn' )

              # `sign_in` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda do
                # see https://github.com/rspec/rspec-rails/issues/65
                # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                request_via_redirect 'GET', private_posts_path, nil, { 'X-User-Email' => user.email, 'X-User-Token' => user.authentication_token }
              end.should raise_exception(RuntimeError, "`sign_in` was called.")
            end
          end

          context "when the default headers are missing in the request (and no query params are used)" do

            it "does not perform token authentication" do
              user = FactoryGirl.create(:user \
                                 ,email: 'alice@example.com' \
                                 ,authentication_token: 'ExaMpLeTokEn' )

              # `sign_in` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda do
                # see https://github.com/rspec/rspec-rails/issues/65
                # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                request_via_redirect 'GET', private_posts_path, nil, { 'X-User-Email' => user.email }
              end.should raise_exception(RuntimeError, "`authenticate_user!` was called.")
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
      PrivatePostsController
        GET /private_posts
      """
    And the output should match:
      """
          when the default headers are set in the request
            performs token authentication
      """
    And the output should contain:
      """
          when the default headers are missing in the request (and no query params are used)
            does not perform token authentication
      """

  @rspec
  Scenario: Using custom header names
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `sign_in` methods always raise an exception
    And I write to "config/initializers/simple_token_authentication.rb" with:
      """
      SimpleTokenAuthentication.configure do |config|

        # Configure the name of the HTTP headers watched for authentication.
        #
        # Default header names for a given token authenticatable entity follow the pattern:
        #   { entity: { authentication_token: 'X-Entity-Token', email: 'X-Entity-Email'} }
        #
        # When several token authenticatable models are defined, custom header names
        # can be specified for none, any, or all of them.
        #
        # Examples
        #
        #   Given User and SuperAdmin are token authenticatable,
        #   When the following configuration is used:
        #     `config.header_names = { super_admin: { authentication_token: 'X-Admin-Auth-Token' } }`
        #   Then the token authentification handler for User watches the following headers:
        #     `X-User-Token, X-User-Email`
        #   And the token authentification handler for SuperAdmin watches the following headers:
        #     `X-Admin-Auth-Token, X-SuperAdmin-Email`
        #
        # (temporary commented out) config.header_names = { user: { authentication_token: 'X-User-Auth-Token', email: 'X-User-Email' } }

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
    And I write to "spec/requests/private_posts_controller_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePostsController" do
        describe "GET /private_posts" do

          context "when an initializer overrides the header_names default value" do

            # See config/initializers/simple_token_authentication.rb

            context "and the custom headers are set in the request" do

              it "performs token authentication" do
                user = FactoryGirl.create(:user \
                                   ,email: 'alice@example.com' \
                                   ,authentication_token: 'ExaMpLeTokEn' )

                # `sign_in` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda do
                  # see https://github.com/rspec/rspec-rails/issues/65
                  # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                  request_via_redirect 'GET', private_posts_path, nil, { 'X-User-Email' => user.email, 'X-User-Auth-Token' => user.authentication_token }
                end.should raise_exception(RuntimeError, "`sign_in` was called.")
              end
            end
            context "and the custom headers are missing in the request (and no query params are used)" do
              context "even if the default headers are set in the request" do

                it "does not perform token authentication" do
                  user = FactoryGirl.create(:user \
                                     ,email: 'alice@example.com' \
                                     ,authentication_token: 'ExaMpLeTokEn' )

                  # `authenticate_user!` is configured to raise an exception when called,
                  # see spec/dummy/app/controllers/application_controller.rb
                  lambda do
                    # see https://github.com/rspec/rspec-rails/issues/65
                    # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                    request_via_redirect 'GET', private_posts_path, nil, { 'X-User-Email' => user.email, 'X-User-Token' => user.authentication_token }
                  end.should raise_exception(RuntimeError, "`authenticate_user!` was called.")
                end
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
      PrivatePostsController
        GET /private_posts
      """
      And the output should match:
      """
          when an initializer overrides the header_names default value
            and the custom headers are set in the request
              performs token authentication
      """
      And the output should match:
      """
            and the custom headers are missing in the request (and no query params are used)
              even if the default headers are set in the request
                does not perform token authentication
      """
