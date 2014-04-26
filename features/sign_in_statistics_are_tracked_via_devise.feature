# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/51
Feature: Sign in statistics are tracked via Devise
  As a developer
  In order to collect statistics about signins
  I want simple_token_authentication to integrate with Devise trackable strategy

  @rspec
  Scenario: sign_in_count is updated when signing with SessionsController#create
    Given I have a dummy app with a Devise-enabled User
    And I prepare the test database

    And User `acts_as_token_authenticatable`

    And I write to "spec/requests/sign_in_spec.rb" with:
      """
      require 'spec_helper'

      describe "Sign in" do
        
        context "with valid credentials" do

          before do
            @user = User.create!(:email => "valid@email.com", :password => "goodpassword")
          end

          it "updates sign in count" do
            expect do
              post user_session_path, { :user => { :email => "valid@email.com", :password => "goodpassword" } }
            end.to change { @user.reload.sign_in_count }.by(1)
          end
        end
      end
      """

    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      Sign in
        with valid credentials
          updates sign in count
      """


  @rspec
  Scenario: sign_in_count is not updated when making token-authenticated request
    Given I have a dummy app with a Devise-enabled User
    And I prepare the test database

    And User `acts_as_token_authenticatable`
    And a scaffolded PrivatePost
    And PrivatePostsController `acts_as_token_authentication_handler`
    And I prepare the test database

    And I write to "spec/requests/token_authenticated_request_spec.rb" with:
      """
      require 'spec_helper'

      describe "Token-authenticated request" do
        
        context "with valid email and token" do

          before do
            @user = User.create!(:email => "valid@email.com", :password => "goodpassword")
          end

          it "does not update sign in count" do
            expect do
              get private_posts_path, { :user_email => "valid@email.com", :user_token => @user.authentication_token }
            end.not_to change { @user.reload.sign_in_count }
          end
        end
      end
      """

    When I run `rspec spec/requests/token_authenticated_request_spec.rb --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      Token-authenticated request
        with valid email and token
          does not update sign in count
      """
