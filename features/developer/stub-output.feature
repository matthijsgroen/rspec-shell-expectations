Feature:
  In order to simulate command behaviour
  As a developer
  I want to stub the output of a command

  Scenario: Stub standard-out
    Given I have the shell script
      """
      command_call 1> file.txt
      """
    And I have stubbed "command_call"
    And the stubbed command outputs "hello there" to standard-out
    When I run this script in a simulated environment
    Then the file "file.txt" contains "hello there"

  Scenario: Stub standard-error
    Given I have the shell script
      """
      command_call 2> file.txt
      """
    And I have stubbed "command_call"
    And the stubbed command outputs "hello there" to standard-error
    When I run this script in a simulated environment
    Then the file "file.txt" contains "hello there"

  Scenario: Stub to file
    Given I have the shell script
      """
      command_call
      """
    And I have stubbed "command_call"
    And the stubbed command outputs "hello there" to "file.txt"
    And the stubbed command outputs "there" to "other_file.txt"
    When I run this script in a simulated environment
    Then the file "file.txt" contains "hello there"
    And the file "other_file.txt" contains "there"

