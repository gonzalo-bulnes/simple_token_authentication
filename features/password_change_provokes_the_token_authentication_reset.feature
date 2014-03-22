# See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/26
Feature: Password change provokes the authentication token reset
  As an user
  In order to ensure no-one can take advantage of my previous credentials
  I want my authentication token to become invalid when I change my password

  @rspec
  Scenario: After password change, the authentication token is renewed
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

          let!(:user) do
            FactoryGirl.create(:user \
                               ,email: 'alice@example.com' \
                               ,authentication_token: 'ExaMpLeTokEn' )
          end

          context "while password hasn't been renewed" do
            context "when the original authentication token is used" do
              it "performs token authentication" do

                # `sign_in` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda do
                  # see https://github.com/rspec/rspec-rails/issues/65
                  # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                  request_via_redirect 'GET', private_posts_path, nil, { 'X-User-Email' => user.email, 'X-User-Token' => 'ExaMpLeTokEn' }
                end.should raise_exception(RuntimeError, "`sign_in` was called.")
              end
            end
          end

          context "once the password has been changed" do
            context "when the original authentication token is used" do

              it "does not perform token authentication" do

                pending "Work in Progress. Not yet implemented."

                # TODO: change the user password, or, at least, call
                # Devise::PasswordsController#update

                # `sign_in` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda do
                  # see https://github.com/rspec/rspec-rails/issues/65
                  # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                  request_via_redirect 'GET', private_posts_path, nil, { 'X-User-Email' => user.email, 'X-User-Token' => 'ExaMpLeTokEn' }
                end.should raise_exception(RuntimeError, "`authenticate_user!` was called.")
              end
            end
            context "when the new authentication token is used" do
              it "performs token authentication" do

                # `sign_in` is configured to raise an exception when called,
                # see spec/dummy/app/controllers/application_controller.rb
                lambda do
                  # see https://github.com/rspec/rspec-rails/issues/65
                  # and http://guides.rubyonrails.org/testing.html#helpers-available-for-integration-tests
                  request_via_redirect 'GET', private_posts_path, nil, { 'X-User-Email' => user.email, 'X-User-Token' => user.authentication_token }
                end.should raise_exception(RuntimeError, "`sign_in` was called.")
              end
            end
          end
        end
      end
      """
    And I write to "spec/models/user_spec.rb" with:
      """
      require 'spec_helper'

      describe User do

        # attributes

        specify { expect(subject).to respond_to :authentication_token }

        # validations

        it 'has a valid factory' do
          expect(FactoryGirl.create(:user)).to be_valid
        end

        # methods

        describe '#renew_authentication_token!' do

          let!(:user) { FactoryGirl.create(:user) }

          it 'accepts no arguments' do
            expect{ user.renew_authentication_token!('oops') }.to raise_error
          end

          it 'returns true' do
            expect(user.renew_authentication_token!).to eq true
          end

          it "renews the user's authentication token" do
            original_authentication_token = user.authentication_token
            user.renew_authentication_token!
            expect(user.authentication_token).not_to eq(original_authentication_token)
          end
        end
      end
      """

    And I silence the PrivatePostsController spec errors

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      User
      """
    And the output should match:
      """
        #renew_authentication_token
      """
    And the output should match:
      """
          accepts no arguments
      """
    And the output should match:
      """
          returns true
      """
    And the output should match:
      """
          renews the user's authentication token
      """
    And the output should match:
      """
      PrivatePostsController
        GET /private_posts
      """
    And the output should match:
      """
          while password hasn't been renewed
            when the original authentication token is used
              performs token authentication
      """
    And the output should contain:
      """
          once the password has been changed
      """
    And the output should contain:
      """
            when the original authentication token is used
              does not perform token authentication (PENDING: Work in Progress. Not yet implemented.)
      """
    And the output should contain:
      """
            when the new authentication token is used
              performs token authentication
      """
