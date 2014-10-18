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
      exit 0
      bundle exec rake release
      """
    And I have stubbed "bundle" with args as "rake":
        | args |
        | exec |
        | rake |
    Then the command "rake" with "test" is called
    And the command "rake" with "build" is called
    And the command "rake" with "release" is not called
