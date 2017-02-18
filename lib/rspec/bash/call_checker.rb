require 'rspec/mocks/argument_list_matcher'

class CallChecker
  def called_with?(actual_call_list, expected_argument_list)
    get_call_count(actual_call_list, expected_argument_list) > 0
  end

  def get_call_count(actual_call_list, expected_argument_list)
    argument_list_matcher = RSpec::Mocks::ArgumentListMatcher.new(expected_argument_list)

    matching_call_list = actual_call_list.select do |actual_argument_list|
      argument_list_matcher.args_match?(actual_argument_list)
    end
    matching_call_list.size
  end
end