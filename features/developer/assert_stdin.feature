Feature:
  In order to check the input of a command
  As a developer
  I want to check the standard-in stream

  Scenario: Assert standard-in
    Given I have the shell script
      """
      echo "text to stdin" | command_call
      """
    And I have stubbed "command_call"
    When I run this script in a simulated environment
    Then the command "command_call" has received "text to stdin" from standard-in
