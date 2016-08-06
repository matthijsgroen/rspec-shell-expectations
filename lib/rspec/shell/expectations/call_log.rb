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

        def find_call(*argument_list, position: false)
          argument_list ||= []

          call_log.each do |call|
            call_log_arguments = call['args'] || []
            return call if argument_list.empty?

            call_log_arguments = position ? call_log_arguments[position,argument_list.size] : call_log_arguments
            call_log_arguments_iterator = call_log_arguments.each_cons(argument_list.size)

            return call if call_log_arguments_iterator.include? argument_list
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
