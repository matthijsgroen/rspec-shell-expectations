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
          return true if find_call(*args)
          false
        end

        def stdin_for_args(*args)
          call = find_call(*args)
          return call['stdin'] if call
          nil
        end

        private

        def find_call(*args)
          call_log.each do |call|
            call_args = call['args'] || []
            return call if (args - call_args).empty?
          end
          nil
        end

        def call_log
          YAML.load_file @call_log_path
        end
      end
    end
  end
end
