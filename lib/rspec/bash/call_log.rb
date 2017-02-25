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

      def stdin_for_args(*argument_list)
        call_argument_list_matcher = CallLogArgumentListMatcher.new(*argument_list)
        matching_call_log_list = call_argument_list_matcher.get_call_log_matches(call_log_list)
        matching_call_log_list.first['stdin'] unless matching_call_log_list.empty?
      end

      def call_count(*argument_list)
        call_argument_list_matcher = CallLogArgumentListMatcher.new(*argument_list)
        call_argument_list_matcher.get_call_count(call_log_list)
      end

      def called_with_args?(*argument_list)
        call_argument_list_matcher = CallLogArgumentListMatcher.new(*argument_list)
        call_argument_list_matcher.args_match?(call_log_list)
      end

      def called_with_no_args?
        !call_log_arguments.empty? && call_log_arguments.all?(&:empty?)
      end

      private

      def call_log_arguments
        call_log_list.map { |call_log| call_log['args'] || [] }.compact
      end

      def call_log_stdin
        call_log_list.map { |call_log| call_log['stdin'] || [] }.compact
      end

      def call_log_list
        YAML.load_file @call_log_path
      rescue Errno::ENOENT
        return []
      end
    end
  end
end
