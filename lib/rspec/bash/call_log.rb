module Rspec
  module Bash
    class CallLog
      def initialize(call_log_path)
        @call_log_path = call_log_path
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
        return false if call_log.empty?

        call_log.all? do |call_log|
          argument_list = call_log[:args] || []
          argument_list.empty?
        end
      end

      def add_log(stdin, argument_list)
        updated_log = call_log
        updated_log << {
          args: argument_list,
          stdin: stdin
        }
        write updated_log
      end

      def call_log
        @call_log_path.open('r') do |call_log|
          YAML.load(call_log.read) || []
        end
      rescue NoMethodError, Errno::ENOENT
        return []
      end

      def call_log=(new_log)
        write new_log
      end

      def call_log_arguments
        load_call_log_list.map { |call_log| call_log['args'] || [] }.compact
      end

      private

      def write(call_log_to_write)
        @call_log_path.open('w') do |call_log|
          call_log.write call_log_to_write.to_yaml
        end
      end
    end
  end
end
