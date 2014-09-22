# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/75
Feature: The skip trackable option can be configured via an initializer
  As a developer
  In order to track when an user logged with a token
  I want an the skip_trackable option to be available and configurable

  @rspec
  Scenario: Without intializer, the sign_in_count is not incremented after authentication
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` method always raises an exception
    And the `sign_in` method always raises an exception to show its options
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler` through:
      """
      acts_as_token_authentication_handler_for User
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
          sign_in_count 0
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

            it "does not increment the sign_in_count by default" do
                user.reload
                user.sign_in_count.should eq(0)
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
            does not increment the sign_in_count by default
      """

  @rspec
  Scenario: Override the skip_trackable option value with an initalizer
    Given I have a dummy app with a Devise-enabled User
    And a scaffolded PrivatePost
    And I prepare the test database
    And the `authenticate_user!` method always raises an exception
    And the `sign_in` method always raises an exception to show its options
    And I write to "config/initializers/simple_token_authentication.rb" with:
      """
      SimpleTokenAuthentication.configure do |config|

        # Configure the trackable policy. By default this module is deactivated as sign in using
        # token should not be tracked by Devise trackable.
        # If false, trackable module must be configured in your model(s)
        # config.skip_trackable = true
        config.skip_trackable = false
      end
      """
    And User `acts_as_token_authenticatable`
    And PrivatePostsController `acts_as_token_authentication_handler` through:
      """
      acts_as_token_authentication_handler_for User
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
          sign_in_count 0
        end
      end
      """
    And I write to "spec/requests/private_posts_spec.rb" with:
      """
      require 'spec_helper'

      describe "PrivatePosts" do
        describe "GET /private_posts" do

          context "when an initializer overrides the skip_trackable default value" do

            # See config/initializers/simple_token_authentication.rb

            context "and authentication is successful" do

              let(:user) do
                FactoryGirl.create(:user \
                                   ,email: 'alice@example.com' \
                                   ,authentication_token: 'ExaMpLeTokEn' )
              end

              it "increment the sign_in_count value" do
                user.reload
                user.sign_in_count.should eq(1)
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
              increment the sign_in_count value
      """
