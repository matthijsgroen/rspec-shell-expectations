Feature:
  In order to run scripts without triggering real commands
  As a developer
  I want to stub commands

  Scenario: Run a script without stub
    Given I have the shell script
      """
      command_that_does_not_exist
      """
    When I run this script in a simulated environment
    Then the exitstatus will not be 0

  Scenario: Run a script with stub
    Given I have the shell script
      """
      command_that_does_not_exist
      """
    And I have stubbed "command_that_does_not_exist"
    When I run this script in a simulated environment
    Then the exitstatus will be 0
