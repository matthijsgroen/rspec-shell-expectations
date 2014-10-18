Feature:
  In order to make sure the script reaches a certain point
  As a developer
  I want to assert a command call

  Scenario: Assert command call
    Given I have the shell script
      """
      command_call
      """
    And I have stubbed "command_call"
    And I have stubbed "other_call"
    When I run this script in a simulated environment
    Then the command "command_call" is called
    And the command "other_call" is not called
