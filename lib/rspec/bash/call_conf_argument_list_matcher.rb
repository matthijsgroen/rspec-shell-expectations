require 'rspec/mocks/argument_list_matcher'
include RSpec::Mocks
include RSpec::Mocks::ArgumentMatchers

module Rspec
  module Bash
    class CallConfArgumentListMatcher < ArgumentListMatcher
      alias parent_args_match? args_match?
      alias parent_initialize initialize

      def initialize(expected_call_conf_list)
        @expected_call_conf_list = expected_call_conf_list
      end

      def args_match?(*actual_call_arguments)
        !get_call_conf_matches(*actual_call_arguments).empty?
      end

      def get_call_conf_matches(*actual_call_arguments)
        @expected_call_conf_list.select do |expected_call_conf|
          expected_call_conf_args = expected_call_conf[:args]
          @expected_args = expected_call_conf_args.empty? ? [any_args] : expected_call_conf_args
          parent_args_match?(*actual_call_arguments)
        end
      end
    end
  end
end
