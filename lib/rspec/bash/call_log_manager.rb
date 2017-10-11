module Rspec
  module Bash
    class CallLogManager
      def initialize()
        @call_logs = Hash.new { |hash, key| hash[key] = CallLog.new }
      end
      def add_log(command, stdin, arguments)
        @call_logs[command]
          .add_log(stdin, arguments)
      end
      def stdin_for_args(command, arguments)
        @call_logs[command]
          .stdin_for_args(arguments)
      end
      def call_count(command, arguments)
        @call_logs[command]
          .call_count(arguments)
      end
      def called_with_args?(command, arguments)
        @call_logs[command]
          .called_with_args?(arguments)
      end
      def called_with_no_args?(command)
        @call_logs[command]
          .called_with_no_args?
      end
      def call_log(command)
        @call_logs[command]
      end
    end
  end
end
