# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/28
Feature: Any model can act as token authenticatable
  As a developer
  In order to protect some models with token authentication
  I want any Devise-enabled model (not only User) to be able to act as token authenticatable

  @rspec
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

  @rspec
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

  @rspec
  Scenario: `User` and `Admin` both act as token authenticatable (Part 1)
    Given I have a dummy app with a Devise-enabled User and Admin
    And a scaffolded PrivatePost
    And a scaffolded VeryPrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `authenticate_admin!` methods always raise an exception

    And User `acts_as_token_authenticatable`
    And Admin `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` User

    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "since User `acts_as_authenticatable`" do
            context "and PrivatePostsController `acts_as_authentication_handler_for User`" do

              # See spec/dummy/app/controllers/private_posts_controller.rb

              it "does call `authenticate_user!`" do
                # `authenticate_user!` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda { get private_posts_path }.should raise_exception(RuntimeError, "`authenticate_user!` was called.")
              end
            end
          end
          context "despite Admin `acts_as_token_authenticatable`" do
            context "since PrivatePostsController does not act as authentication handler for Admin" do

              # See spec/dummy/app/controllers/private_posts_controller.rb

              it "does not call `authenticate_admin!`" do
                # `authenticate_addmin!` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda { get private_posts_path }.should_not raise_exception(RuntimeError, "`authenticate_admin!` was called.")
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
      """
    And the output should match:
      """
          since User `acts_as_authenticatable`
            and PrivatePostsController `acts_as_authentication_handler_for User`
              does call `authenticate_user!`
      """
    And the output should match:
      """
          despite Admin `acts_as_token_authenticatable`
            since PrivatePostsController does not act as authentication handler for Admin
              does not call `authenticate_admin!`
      """

  @rspec
  Scenario: `User` and `Admin` both act as token authenticatable (Part 2)
    Given I have a dummy app with a Devise-enabled User and Admin
    And a scaffolded PrivatePost
    And a scaffolded VeryPrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `authenticate_admin!` methods always raise an exception

    And User `acts_as_token_authenticatable`
    And Admin `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler_for` Admin

    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "since Admin `acts_as_authenticatable`" do
            context "and PrivatePostsController `acts_as_authentication_handler_for Admin`" do

              # See spec/dummy/app/controllers/private_posts_controller.rb

              it "does call `authenticate_admin!`" do
                # `authenticate_admin!` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda { get private_posts_path }.should raise_exception(RuntimeError, "`authenticate_admin!` was called.")
              end
            end
          end
          context "despite User `acts_as_token_authenticatable`" do
            context "since PrivatePostsController does not act as authentication handler for User" do

              # See spec/dummy/app/controllers/private_posts_controller.rb

              it "does not call `authenticate_user!`" do
                # `authenticate_addmin!` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda { get private_posts_path }.should_not raise_exception(RuntimeError, "`authenticate_user!` was called.")
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
      """
    And the output should match:
      """
          since Admin `acts_as_authenticatable`
            and PrivatePostsController `acts_as_authentication_handler_for Admin`
              does call `authenticate_admin!`
      """
    And the output should match:
      """
          despite User `acts_as_token_authenticatable`
            since PrivatePostsController does not act as authentication handler for User
              does not call `authenticate_user!`
      """
