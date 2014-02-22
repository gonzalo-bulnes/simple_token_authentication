# See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/32
Feature: Defaults can be modifed via an initializer
  As a developer
  In order to set the defaults I prefer
  And to do it in the way I use to
  I want a configuration mecanisme to be avaiable which allow me to override the gem defaults from an initializer file

  Scenario: Without intializer, the sign_in_token option defaults to false
    Given I have a dummy app with a Devise-enabled User
    And I prepare the test database
    And I write to "spec/models/simple_token_authentication/configuration_spec.rb" with:
      """
      require 'spec_helper'

      describe SimpleTokenAuthentication do
        describe "sign_in_token option" do

          subject { SimpleTokenAuthentication.sign_in_token }

          it "does not store the user in the session by default" do
            expect(subject).to be_false
          end
        end
      end
      """
    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      SimpleTokenAuthentication
        sign_in_token option
          does not store the user in the session by default
      """

  Scenario: Override the sign_in_token option value with an initalizer
    Given I have a dummy app with a Devise-enabled User
    And I prepare the test database
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
    And I write to "spec/models/simple_token_authentication/configuration_spec.rb" with:
      """
      require 'spec_helper'

      describe SimpleTokenAuthentication do
        describe "sign_in_token option" do

          subject { SimpleTokenAuthentication.sign_in_token }

          context "when an initializer overrides it's default value" do

            # See config/initializers/simple_token_authentication.rb

            it "stores the user in the session" do
              expect(subject).to be_true
            end
          end
        end
      end
      """
    When I run `rspec --format documentation`
    Then the exit status should be 0
    And the output should match:
      """
      SimpleTokenAuthentication
        sign_in_token option
          when an initializer overrides it's default value
            stores the user in the session
      """
