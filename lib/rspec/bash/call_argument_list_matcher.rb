require 'rspec/mocks/argument_list_matcher'

class CallArgumentListMatcher < RSpec::Mocks::ArgumentListMatcher
  alias_method :parent_args_match?, :args_match?

  def args_match?(actual_call_list)
    get_call_count(actual_call_list) > 0
  end

  def get_call_count(actual_call_list)
    matching_call_list = actual_call_list.select do |actual_argument_list|
      parent_args_match?(actual_argument_list)
    end
    matching_call_list.size
  end
end