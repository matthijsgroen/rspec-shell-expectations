module Rspec
  module Bash
    class CallLog
      attr_accessor :call_log

      def initialize
        @call_log = []
      end

      def stdin_for_args(argument_list)
        call_argument_list_matcher = Util::CallLogArgumentListMatcher.new(argument_list)
        matching_call_log_list = call_argument_list_matcher.get_call_log_matches(call_log)
        matching_call_log_list.first[:stdin] unless matching_call_log_list.empty?
      end

      def call_count(argument_list)
        call_argument_list_matcher = Util::CallLogArgumentListMatcher.new(argument_list)
        call_argument_list_matcher.get_call_count(call_log)
      end

      def called_with_args?(argument_list)
        call_argument_list_matcher = Util::CallLogArgumentListMatcher.new(argument_list)
        call_argument_list_matcher.args_match?(call_log)
      end

      def called_with_no_args?
        return false if @call_log.empty?

        @call_log.all? do |call_log|
          argument_list = call_log[:args] || []
          argument_list.empty?
        end
      end

      def add_log(stdin, argument_list)
        updated_log = @call_log
        updated_log << {
          args: argument_list,
          stdin: stdin
        }
      end

      def call_log_arguments
        @call_log.map { |call_log| call_log[:args] || [] }.compact
      end
    end
  end
end
