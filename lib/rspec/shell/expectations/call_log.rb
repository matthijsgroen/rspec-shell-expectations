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

        def find_call(*argument_list, sub_command_list: [], position: false)
          argument_list ||= []
          argument_list_size = argument_list.size

              call_log(sub_command_list).each do |call|
            call_log_arguments = call['args'] || []
            return call if argument_list.empty?

            if position and ! sub_command_list.empty?
              position += sub_command_list.size
            end

            call_log_arguments = position ? call_log_arguments[position,argument_list_size] : call_log_arguments
            call_log_arguments_iterator = call_log_arguments.each_cons(argument_list_size)

            return call if call_log_arguments_iterator.include? argument_list
          end
          nil
        end

        def call_log(sub_command_list)
          call_log = YAML.load_file @call_log_path
          sub_command_list.empty? ? call_log : call_log.select { |call_log_item|
            args = call_log_item['args'] || []
            args[0..sub_command_list.size - 1] == sub_command_list
          }
        end
      end
    end
  end
end
