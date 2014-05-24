# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/64
Feature: Several token authenticatable models (Devise scopes) can be used with the same token autentication handler
  As a developer
  In order to be able to authenticate with several distinct models (e.g. `User` and `Admin`) for a same action (e.g. PrivatePostsController#index)
  I want any token authentication handler to be able to deal with several token authenticatable models (Devise scopes)

  @rspe
  Scenario: `User` and `Admin` both act as token authenticatable (Part 3)
    Given I have a dummy app with a Devise-enabled User and Admin
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` and `authenticate_admin!` methods always raise an exception
    And the `sign_in` method always raises an exception to show its resource or scope

    And User `acts_as_token_authenticatable`
    And Admin `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler` through:
      """
        acts_as_token_authentication_handler_for User, fallback_to_devise: false
        acts_as_token_authentication_handler_for Admin
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
    And I write to "spec/factories/admins.rb" with:
      """
      FactoryGirl.define do

        factory :admin do
          email
          password  "password"
          password_confirmation "password"
        end
      end
      """
    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'
      require 'factory_girl_rails'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "since User and Admin act as token authenticatable" do
            context "and PrivatePostsController `acts_as_token_authentication_handler_for` both" do

              context "when no credentials are provided" do

                # See spec/dummy/app/controllers/private_posts_controller.rb

                it "no token authentication is performed" do
                  # `authenticate_user!` is configured to raise an exception when called,
                  # see spec/dummy/app/controllers/application_controller.rb
                  lambda { get private_posts_path }.should raise_exception(RuntimeError, '`authenticate_admin!` was called.')
                end
              end

              context "when Admin credentials are provided" do

                let(:admin) { FactoryGirl.create(:admin) }

                # See spec/dummy/app/controllers/private_posts_controller.rb

                it "token authentication is performed for that Admin" do
                  # `authenticate_user!` is configured to raise an exception when called,
                  # see spec/dummy/app/controllers/application_controller.rb
                  lambda do
                    get private_posts_path, { admin_email: admin.email, \
                                              admin_token: admin.authentication_token }
                  end.should raise_exception(RuntimeError, '`sign_in` was called with resource or scope `Admin`.')
                end
              end

              context "when User credentials are provided" do

                let(:user) { FactoryGirl.create(:user) }

                # See spec/dummy/app/controllers/private_posts_controller.rb

                it "token authentication is performed for that User" do
                  # `authenticate_user!` is configured to raise an exception when called,
                  # see spec/dummy/app/controllers/application_controller.rb
                  lambda do
                    get private_posts_path, { user_email: user.email, \
                                              user_token: user.authentication_token }
                  end.should raise_exception(RuntimeError, '`sign_in` was called with resource or scope `User`.')
                end
              end

              context "when User and Admin credentials are provided" do

                let(:user) { FactoryGirl.create(:user) }
                let(:admin) { FactoryGirl.create(:admin) }

                # See spec/dummy/app/controllers/private_posts_controller.rb

                it "token authentication is performed for User" do
                  # `authenticate_user!` is configured to raise an exception when called,
                  # see spec/dummy/app/controllers/application_controller.rb
                  lambda do
                    get private_posts_path, { user_email: user.email, \
                                              user_token: user.authentication_token, \
                                              admin_email: admin.email, \
                                              admin_token: admin.authentication_token }
                  end.should raise_exception(RuntimeError, '`sign_in` was called with resource or scope `User`.')
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
      PrivatePosts
        GET /private_posts
          since User and Admin act as token authenticatable
            and PrivatePostsController `acts_as_token_authentication_handler_for` both
      """
    And the output should match:
      """
              when no credentials are provided
                no token authentication is performed
      """
    And the output should match:
      """
              when Admin credentials are provided
                token authentication is performed for that Admin
      """
    And the output should match:
      """
              when User credentials are provided
                token authentication is performed for that User
      """
    And the output should match:
      """
              when User and Admin credentials are provided
                token authentication is performed for User
      """
