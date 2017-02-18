require 'spec_helper'

describe 'CallChecker' do
  subject { CallChecker.new }
  context '#get_call_count' do
    context 'given a call list with a with multiple sets of arguments' do
      let(:call_list) do
        [
            %w(first_argument second_argument),
            %w(first_argument second_argument third_argument),
            %w(first_argument second_argument)
        ]
      end

      it 'returns the correct count for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        actual_match_count = subject.get_call_count(call_list, argument_list_to_match)
        expect(actual_match_count).to be 1
      end

      it 'returns the correct count for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        actual_match_count = subject.get_call_count(call_list, argument_list_to_match)
        expect(actual_match_count).to be 2
      end

      it 'returns the correct count for no argument matches' do
        argument_list_to_match = %w(first_argument)
        actual_match_count = subject.get_call_count(call_list, argument_list_to_match)
        expect(actual_match_count).to be 0
      end

      it 'returns the correct count for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        actual_match_count = subject.get_call_count(call_list, argument_list_to_match)
        expect(actual_match_count).to be 1
      end

      it 'returns the correct count for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        actual_match_count = subject.get_call_count(call_list, argument_list_to_match)
        expect(actual_match_count).to be 2
      end

      it 'returns the correct count for "anything" matches that are not the exact count' do
        argument_list_to_match = [anything, anything, anything, anything]
        actual_match_count = subject.get_call_count(call_list, argument_list_to_match)
        expect(actual_match_count).to be 0
      end
    end
  end
  context '#called_with?' do
    context 'given a call list with a with multiple sets of arguments' do
      let(:call_list) do
        [
            %w(first_argument second_argument),
            %w(first_argument second_argument third_argument),
            %w(first_argument second_argument)
        ]
      end

      it 'returns true for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        actual_match_count = subject.called_with?(call_list, argument_list_to_match)
        expect(actual_match_count).to be true
      end

      it 'returns true for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        actual_match_count = subject.called_with?(call_list, argument_list_to_match)
        expect(actual_match_count).to be true
      end

      it 'returns false for no argument matches' do
        argument_list_to_match = %w(first_argument)
        actual_match_count = subject.called_with?(call_list, argument_list_to_match)
        expect(actual_match_count).to be false
      end

      it 'returns true for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        actual_match_count = subject.called_with?(call_list, argument_list_to_match)
        expect(actual_match_count).to be true
      end

      it 'returns true for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        actual_match_count = subject.called_with?(call_list, argument_list_to_match)
        expect(actual_match_count).to be true
      end

      it 'returns false for "anything" matches that are not the exact count' do
        argument_list_to_match = [anything, anything, anything, anything]
        actual_match_count = subject.get_call_count(call_list, argument_list_to_match)
        expect(actual_match_count).to be 0
      end
    end
  end
end