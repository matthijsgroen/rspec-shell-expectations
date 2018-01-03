require 'rspec/expectations'

RSpec::Matchers.define :be_called_with_no_arguments do
  match(&:called_with_no_args?)
end
