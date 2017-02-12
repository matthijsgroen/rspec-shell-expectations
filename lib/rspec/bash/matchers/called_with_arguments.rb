require 'rspec/expectations'

RSpec::Matchers.define :be_called_with_arguments do |*expected_argument_list|
  chain :times do |expected_invocations|
    @expected_invocations = expected_invocations
  end

  match do |actual_command|
    called_with_correct_args = actual_command.called_with_args?(*expected_argument_list)

    if @expected_invocations
      called_correct_number_of_times =
        actual_command.call_count(*expected_argument_list) == @expected_invocations
    else
      called_correct_number_of_times = true
    end

    called_with_correct_args && called_correct_number_of_times
  end

  failure_message do |actual_command|
    command_name = actual_command.command

    formatted_expected_call = "#{command_name} #{expected_argument_list.join(' ')}"
    formatted_actual_calls = actual_command.call_log.call_log_arguments.map do |arg_array|
      "#{command_name} #{arg_array.join(' ')}"
    end.join("\n")

    "Expected #{actual_command.command} to be called with arguments #{expected_argument_list}\n\n" \
      "Expected Calls:\n#{formatted_expected_call}\n\n" \
      "Actual Calls:\n#{formatted_actual_calls}\n"
  end

  failure_message_when_negated do |actual_command|
    "Expected #{actual_command.command} not to be called with arguments #{expected_argument_list}"
  end
end
