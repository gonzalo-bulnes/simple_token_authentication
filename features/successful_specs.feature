Feature: Smoke test
  As a developer
  In order to be able to setup the dummy app with different RSpec specs depending of the feature I want to test
  And to drive the dummy app setup with Cucumber and Aruba
  I want to be able to programatically run RSpec within the dummy app

  @rspec
  Scenario: Run RSpec within the context of the dummy app
    Given I have a dummy app
    When I run `rspec`
    Then the exit status should be 0
    And the output should match:
      """
      0 failures
      """
