require 'rspec/expectations'

RSpec::Matchers.define :be_called_with_no_arguments do
  match do |actual_command|
   actual_command.called_with_no_args?
  end
end
