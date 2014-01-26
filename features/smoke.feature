Feature: Smoke test
  As a developer
  In order to make sure Cucumber and Aruba are correctly configured
  I want to run a smoke test

  Scenario: Create a directory with Aruba
    Given a directory named "test_directory"
    When I cd to "test_directory"
    Then the output should not match:
    """
    No such file or directory
    """
