require 'rspec/expectations'

RSpec::Matchers.define :be_called_with_arg do |argument|
  match do |stubbed_command|
    @do_match ||= lambda { |actual_arguments, expected_argument|
      actual_arguments.include? expected_argument
    }

    call_log = get_call_log stubbed_command
    call_log.each do |call_log_item|
      actual_arguments = call_log_item['args']

      return true if @do_match.call(actual_arguments,argument)
    end

    false
  end

  chain :at_position do |argument_position|
    @do_match = lambda { |actual_arguments, expected_argument|
      actual_arguments[argument_position] == expected_argument
    }
  end

  chain :with_flag do |expected_flag|
    @do_match = lambda { |actual_arguments, expected_argument|
      expected_flag_index = actual_arguments.find_index(expected_flag)
      actual_arguments[expected_flag_index + 1] == expected_argument unless !expected_flag_index
    }
  end

  chain :times do |expected_invocations|
    @do_match = lambda { |actual_arguments, expected_argument|
      actual_arguments.count(expected_argument) == expected_invocations
    }
  end

  failure_message do |stubbed_command|
    print_failure_message stubbed_command
  end

  failure_message_when_negated do |stubbed_command|
    print_failure_message stubbed_command
  end

  def print_failure_message(stubbed_command)
    "actual: #{get_call_log(stubbed_command)}"
  end

  def get_call_log(stubbed_command)
    YAML.load_file(stubbed_command.instance_variable_get('@call_log').instance_variable_get('@call_log_path'))
  end



end

