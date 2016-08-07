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
          contains_argument_series?(*args)
        end

        def stdin_for_args(*args)
          call = find_call(*args)
          return call['stdin'] if call
          nil
        end

        def contains_argument_series?(*expected_argument_series, sub_command_series: [], position: false)
          expected_argument_series ||= []
          return true if expected_argument_series.empty?

          call_log_list = load_call_log_list
          sub_command_argument_list = extract_sub_command_arguments_from_call_log(call_log_list, sub_command_series)
          position_range_argument_list = extract_position_range_from_argument_list(sub_command_argument_list, position, expected_argument_series.size)

          position_range_argument_list.each do |actual_argument_series|
            return true if argument_series_contains?(actual_argument_series, expected_argument_series)
          end

          false
        end

        private

        def find_call(*args)
          load_call_log_list.each do |call|
            call_args = call['args'] || []
            return call if (args - call_args).empty?
          end
          nil
        end

        def extract_sub_command_arguments_from_call_log(call_log_list, sub_command_list)
          call_log_list.map { |call_log|
            call_log_argument_series = call_log['args'] || []

            next call_log_argument_series if sub_command_list.empty?
            next call_log_argument_series if call_log_argument_series.slice!(0, sub_command_list.size) == sub_command_list
          }.compact
        end

        def extract_position_range_from_argument_list(argument_list, range_start_position, range_length)
          argument_list.map { |argument_series|
            range_start_position ? argument_series[range_start_position, range_length] : argument_series
          }
        end

        def argument_series_contains?(actual_argument_sequence, expected_argument_sequence)
          actual_argument_sequence.each_cons(expected_argument_sequence.size).include? expected_argument_sequence
        end

        def load_call_log_list
          YAML.load_file @call_log_path
        end
      end
    end
  end
end
