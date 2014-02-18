# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/28
Feature: Any model can act as token authenticatable
  As a developer
  In order to protect some models with token authentication
  I want any Devise-enabled model (not only User) to be able to act as token authenticatable

  Scenario: `User` acts as the only token authenticatable model
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` method always raises an exception
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` User
    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "since User `acts_as_authenticatable`" do

            # See spec/dummy/app/controllers/private_posts_controller.rb

            it "does call `authenticate_user!`" do
              # `authenticate_user!` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda { get private_posts_path }.should raise_exception(RuntimeError)
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
          since User `acts_as_authenticatable`
            does call `authenticate_user!`
      """

  Scenario: `ApiAdmin` acts as the only token authenticatable model
    Given I have a dummy app with a Devise-enabled ApiAdmin
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_api_admin!` method always raises an exception
    And ApiAdmin `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` ApiAdmin
    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "since ApiAdmin `acts_as_authenticatable`" do

            # See spec/dummy/app/controllers/private_posts_controller.rb

            it "does call `authenticate_api_admin!`" do
              # `authenticate_api_admin!` is configured to raise an exception when called,
              # see spec/dummy/app/controllers/application_controller.rb
              lambda { get private_posts_path }.should raise_exception(RuntimeError)
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
          since ApiAdmin `acts_as_authenticatable`
            does call `authenticate_api_admin!`
      """
