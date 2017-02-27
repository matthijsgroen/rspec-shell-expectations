module Rspec
  module Bash
    class CallLog
      def initialize(call_log_path)
        @call_log_path = call_log_path
        @call_log = []
      end

      def exist?
        @call_log_path.exist?
      end

      def stdin_for_args(*argument_list)
        call_argument_list_matcher = Util::CallLogArgumentListMatcher.new(*argument_list)
        matching_call_log_list = call_argument_list_matcher.get_call_log_matches(call_log)
        matching_call_log_list.first[:stdin] unless matching_call_log_list.empty?
      end

      def call_count(*argument_list)
        call_argument_list_matcher = Util::CallLogArgumentListMatcher.new(*argument_list)
        call_argument_list_matcher.get_call_count(call_log)
      end

      def called_with_args?(*argument_list)
        call_argument_list_matcher = Util::CallLogArgumentListMatcher.new(*argument_list)
        call_argument_list_matcher.args_match?(call_log)
      end

      def called_with_no_args?
        !call_log_arguments.empty? && call_log_arguments.all?(&:empty?)
      end

      def add_log(stdin, argument_list)
        @call_log = call_log
        @call_log << {
          args: argument_list,
          stdin: stdin
        }
        write
      end

      def call_log
        return @call_log unless @call_log.empty?
        begin
          @call_log_path.open('r') do |call_log|
            YAML.load(call_log.read) || []
          end
        rescue NoMethodError, Errno::ENOENT
          return []
        end
      end

      def call_log=(new_log)
        @call_log = new_log
      end

      private

      def call_log_arguments
        call_log.map { |call_log| call_log[:args] || [] }.compact
      end

      def write
        @call_log_path.open('w') do |call_log|
          call_log.write @call_log.to_yaml
        end
      end
    end
  end
end
