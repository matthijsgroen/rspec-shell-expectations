module Rspec
  module Bash
    # Log of calls to a command
    class CallLog
      def initialize(call_log_path)
        @call_log_path = call_log_path
      end

      def exist?
        @call_log_path.exist?
      end

      def stdin_for_args(*expected_argument_series)
        call_match_filter = call_matches(*expected_argument_series)
        matching_calls = call_log_stdin.select.with_index do |_, index|
          call_match_filter[index]
        end
        matching_calls.first
      end

      def call_matches(*expected_argument_series)
        call_argument_list_matcher = CallArgumentListMatcher.new(*expected_argument_series)
        call_argument_list_matcher.get_call_matches(call_log_arguments)
      end

      def call_count(*expected_argument_series)
        call_argument_list_matcher = CallArgumentListMatcher.new(*expected_argument_series)
        call_argument_list_matcher.get_call_count(call_log_arguments)
      end

      def called_with_args?(*expected_argument_series)
        call_argument_list_matcher = CallArgumentListMatcher.new(*expected_argument_series)
        call_argument_list_matcher.args_match?(call_log_arguments)
      end

      def called_with_no_args?
        call_log_list = load_call_log_list
        !call_log_list.empty? && call_log_list.first['args'].nil?
      end

      private

      def call_log_arguments
        load_call_log_list.map { |call_log| call_log['args'] || [] }.compact
      end

      def call_log_stdin
        load_call_log_list.map { |call_log| call_log['stdin'] || [] }.compact
      end

      def load_call_log_list
        YAML.load_file @call_log_path
      rescue Errno::ENOENT
        return []
      end
    end
  end
end
