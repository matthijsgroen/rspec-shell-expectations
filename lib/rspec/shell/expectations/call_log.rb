module Rspec
  module Shell
    module Expectations
      # Log of calls to a command
      class CallLog
        def initialize(call_log_path)
          @call_log_path = call_log_path
        end

        def exist?
          @call_log_path.exist?
        end

        def called_with_args?(*args)
          @call_log_path.each_line do |line|
            if (match = /^args:\s(?<args>.*)$/.match(line))
              call_args = match[:args].split('|')
              return true if (args - call_args).empty?
            end
          end
          false
        end
      end
    end
  end
end
