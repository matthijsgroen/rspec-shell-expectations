Feature:
  In order to reduce repetition of arguments
  As a developer
  I want to chain arguments seperately


  Scenario: Chain arguments
    Given I have the shell script
      """
      #!/bin/bash
      bundle exec rake test
      bundle exec rake build
      """
    And I have stubbed "bundle" with args as "rake":
        | args |
        | exec |
        | rake |
    When I run this script in a simulated environment
    Then the command "rake" is called with "test"
    And the command "rake" is called with "build"
