require 'rspec/mocks/argument_list_matcher'
include RSpec::Mocks
include RSpec::Mocks::ArgumentMatchers

module Rspec
  module Bash
    module Util
      class CallConfArgumentListMatcher < ArgumentListMatcher
        alias parent_args_match? args_match?
        alias parent_initialize initialize

        def initialize(call_conf_list)
          @expected_call_conf_list = call_conf_list
        end

        def args_match?(call_arguments)
          !get_call_conf_matches(call_arguments).empty?
        end

        def get_best_call_conf(call_arguments)
          get_call_conf_matches(call_arguments).sort_by do |call_conf|
            [
              call_conf[:args].length
            ]
          end.last || {}
        end

        def get_call_conf_matches(call_arguments)
          @expected_call_conf_list.select do |expected_call_conf|
            @expected_args = remap_argument_matchers(expected_call_conf[:args])
            parent_args_match?(*call_arguments)
          end
        end

        private

        def remap_argument_matchers(expected_call_conf_args)
          expected_call_conf_args.map! do |expected_arg|
            next expected_arg unless expected_arg.is_a?(ArgumentMatchers::SingletonMatcher)
            Object.const_get("#{expected_arg.class}::INSTANCE")
          end
          expected_call_conf_args.empty? ? [any_args] : expected_call_conf_args
        end
      end
    end
  end
end
