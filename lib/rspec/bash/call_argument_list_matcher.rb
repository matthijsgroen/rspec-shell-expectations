require 'rspec/mocks/argument_list_matcher'
include RSpec::Mocks
include RSpec::Mocks::ArgumentMatchers

module Rspec
  module Bash
    class CallArgumentListMatcher < ArgumentListMatcher
      alias parent_args_match? args_match?
      alias parent_initialize initialize

      def initialize(*expected_args)
        expected_args = expected_args.empty? ? [any_args] : expected_args
        parent_initialize(*expected_args)
      end

      def args_match?(actual_call_list)
        get_call_count(actual_call_list) > 0
      end

      def get_call_count(actual_call_list)
        matching_call_list = get_call_matches(actual_call_list) - [false]
        matching_call_list.size
      end

      def get_call_log_matches(actual_call_log_list)
        actual_call_log_list.select do |actual_call_list|
          parent_args_match?(*actual_call_list['args'])
        end
      end

      def get_call_matches(actual_call_list)
        actual_call_list.map do |actual_argument_list|
          parent_args_match?(*actual_argument_list)
        end
      end
    end
  end
end
