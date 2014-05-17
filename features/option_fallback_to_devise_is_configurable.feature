# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/#61
Feature: The `acts_as_token_authentication_handler` filter has a fallback_to_devise option
  As a developer
  In order to build safe API authentication by token
  And to keep being able to use token authentication in non-API scnearii
  I want the fallback_to_devise option to be available at a controller level

  @rspec
  Scenario: Fallback to Devise is enabled by default
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

          context "when the required headers are missing in the request (and no query params are used)" do

            it "does fallback to Devise authentication" do
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
    And the output should contain:
      """
          when the required headers are missing in the request (and no query params are used)
            does fallback to Devise authentication
      """

  @rspec
  Scenario: Fallback to Devise can be disabled for a specific controller
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And a scaffolded ApiPrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `sign_in` methods always raise an exception
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` User with options:
      """
      fallback_to_devise: true
      """
    And ApiPrivatePostsController `acts_as_token_authentication_handler_for` User with options:
      """
      fallback_to_devise: false
      """
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

          context "when the required headers are missing in the request (and no query params are used)" do

            it "does fallback to Devise authentication" do
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
    And I write to "spec/requests/api_private_posts_controller_spec.rb" with:
      """
      require 'spec_helper'

      describe "ApiPrivatePostsController" do
        describe "GET /api_private_posts" do

          context "when the required headers are set in the request" do

            it "performs token authentication as usual" do
              user = FactoryGirl.create(:user \
                                 ,email: 'alice@example.com' \
                                 ,authentication_token: 'ExaMpLeTokEn' )

              # `sign_in` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda do
                # see https://github.com/rspec/rspec-rails/issues/65
                # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                request_via_redirect 'GET', api_private_posts_path, nil, { 'X-User-Email' => user.email, 'X-User-Token' => user.authentication_token  }
              end.should raise_exception(RuntimeError, "`sign_in` was called.")
            end
          end

          context "when the required headers are missing in the request (and no query params are used)" do

            it "does not fallback to Devise authentication" do
              user = FactoryGirl.create(:user \
                                 ,email: 'alice@example.com' \
                                 ,authentication_token: 'ExaMpLeTokEn' )

              # `sign_in` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda do
                # see https://github.com/rspec/rspec-rails/issues/65
                # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                request_via_redirect 'GET', api_private_posts_path, nil, { 'X-User-Email' => user.email }
              end.should_not raise_exception(RuntimeError, "`authenticate_user!` was called.")
            end
          end

        end
      end
      """

    And I silence the PrivatePostsController spec errors

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should contain:
      """
      PrivatePostsController
        GET /private_posts
      """
    And the output should contain:
      """
          when the required headers are missing in the request (and no query params are used)
            does fallback to Devise authentication
      """
    And the output should contain:
      """
      ApiPrivatePostsController
        GET /api_private_posts
      """
    And the output should contain:
      """
          when the required headers are set in the request
            performs token authentication as usual
      """
    And the output should contain:
      """
          when the required headers are missing in the request (and no query params are used)
            does not fallback to Devise authentication
      """
