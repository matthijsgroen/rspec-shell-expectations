Feature:
  In order to simulate an environment better
  As a developer
  I want to provide environment variables with execution

  Scenario: Provide environment variables
    Given I have the shell script
      """
      echo $MESSAGE | command_call
      other_command $CREDENTIAL
      """
    And I have stubbed "command_call"
    And I have stubbed "other_command"
    When I run this script in a simulated environment with env:
      | name       | value            |
      | MESSAGE    | message contents |
      | CREDENTIAL | supa-sekret      |
    Then the command "command_call" has received "message contents" from standard-in
    And the command "other_command" is called with "supa-sekret"

