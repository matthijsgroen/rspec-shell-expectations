require 'rspec/mocks/argument_list_matcher'
include RSpec::Mocks
include RSpec::Mocks::ArgumentMatchers

module Rspec
  module Bash
    module Util
      class CallLogArgumentListMatcher < ArgumentListMatcher
        alias parent_args_match? args_match?
        alias parent_initialize initialize

        def initialize(*expected_args)
          expected_args = expected_args.empty? ? [any_args] : expected_args
          parent_initialize(*expected_args)
        end

        def args_match?(actual_call_log_list)
          get_call_count(actual_call_log_list) > 0
        end

        def get_call_count(actual_call_log_list)
          get_call_log_matches(actual_call_log_list).size
        end

        def get_call_log_matches(actual_call_log_list)
          actual_call_log_list.select do |actual_call_list|
            parent_args_match?(*actual_call_list['args'])
          end
        end
      end
    end
  end
end
