Feature:
  In order to manipulate code paths in scripts
  As a developer
  I want to change the exitstatus of a command

  Scenario: Change exitstatus code unconditional
    Given I have the shell script
      """
      #!/bin/bash
      command_with_status
      """
    And I have stubbed "command_with_status"
    And the stubbed command returns exitstatus 5
    When I run this script in a simulated environment
    Then the exitstatus will be 5

  Scenario: Change exitstatus code when argument matches
    Given I have the shell script
      """
      #!/bin/bash
      command_with_status --flag
      if [ $? -neq 4 ]; then
        exit 3
      fi
      command_with_status --foo
      """
    And I have stubbed "command_with_status" with args:
        | args   |
        | --flag |
    And the stubbed command returns exitstatus 4
    And I have stubbed "command_with_status" with args:
        | args  |
        | --foo |
    And the stubbed command returns exitstatus 5
    When I run this script in a simulated environment
    Then the exitstatus will be 5
