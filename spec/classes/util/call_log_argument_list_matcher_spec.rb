require 'spec_helper'
include Rspec::Bash::Util

describe 'CallLogArgumentListMatcher' do
  context '#get_call_count' do
    context 'given a call log list with a with multiple sets of arguments' do
      let(:call_log_list) do
        [
          {
            stdin: 'first_stdin',
            args: %w(first_argument second_argument)
          },
          {
            stdin: 'second_stdin',
            args: %w(first_argument second_argument third_argument)
          },
          {
            stdin: 'third_stdin',
            args: %w(first_argument second_argument)
          }
        ]
      end

      it 'returns the correct count for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        actual_match_count = subject.get_call_count(call_log_list)
        expect(actual_match_count).to be 1
      end

      it 'returns the correct count for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        actual_match_count = subject.get_call_count(call_log_list)
        expect(actual_match_count).to be 2
      end

      it 'returns the correct count for no argument matches' do
        argument_list_to_match = %w(first_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        actual_match_count = subject.get_call_count(call_log_list)
        expect(actual_match_count).to be 0
      end

      it 'returns the correct count for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        actual_match_count = subject.get_call_count(call_log_list)
        expect(actual_match_count).to be 1
      end

      it 'returns the correct count for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        actual_match_count = subject.get_call_count(call_log_list)
        expect(actual_match_count).to be 2
      end

      it 'returns the correct count for "anything" matches that are not the exact count' do
        argument_list_to_match = [anything, anything, anything, anything]
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        actual_match_count = subject.get_call_count(call_log_list)
        expect(actual_match_count).to be 0
      end

      it 'returns the correct count for a no expected argument list' do
        subject = CallLogArgumentListMatcher.new
        actual_match_count = subject.get_call_count(call_log_list)
        expect(actual_match_count).to be 3
      end
    end
  end

  context '#get_call_log_matches' do
    context 'given a call log list with a with multiple sets of arguments and stdin' do
      let(:call_log_list) do
        [
          {
            stdin: 'first_stdin',
            args: %w(first_argument second_argument)
          },
          {
            stdin: 'second_stdin',
            args: %w(first_argument second_argument third_argument)
          },
          {
            stdin: 'third_stdin',
            args: %w(first_argument second_argument)
          }
        ]
      end

      it 'returns the correct call log entries for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.get_call_log_matches(call_log_list)
        expect(matches).to eql call_log_list.values_at(1)
      end

      it 'returns the correct call log entries for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.get_call_log_matches(call_log_list)
        expect(matches).to eql call_log_list.values_at(0, 2)
      end

      it 'returns the correct call log entries for no argument matches' do
        argument_list_to_match = %w(first_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.get_call_log_matches(call_log_list)
        expect(matches).to eql []
      end

      it 'returns the correct call log entries for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.get_call_log_matches(call_log_list)
        expect(matches).to eql call_log_list.values_at(1)
      end

      it 'returns the correct call log entries for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.get_call_log_matches(call_log_list)
        expect(matches).to eql call_log_list.values_at(0, 2)
      end

      it 'returns the correct call log entries for "anything" matches not matching count' do
        argument_list_to_match = [anything, anything, anything, anything]
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.get_call_log_matches(call_log_list)
        expect(matches).to eql []
      end

      it 'returns the correct call log entries for no expected argument list' do
        subject = CallLogArgumentListMatcher.new
        matches = subject.get_call_log_matches(call_log_list)
        expect(matches).to eql call_log_list
      end
    end
  end

  context '#args_match?' do
    context 'given a call list with a with multiple sets of arguments' do
      let(:call_log_list) do
        [
          {
            stdin: 'first_stdin',
            args: %w(first_argument second_argument)
          },
          {
            stdin: 'second_stdin',
            args: %w(first_argument second_argument third_argument)
          },
          {
            stdin: 'third_stdin',
            args: %w(first_argument second_argument)
          }
        ]
      end

      it 'returns true for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.args_match?(call_log_list)
        expect(matches).to be true
      end

      it 'returns true for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.args_match?(call_log_list)
        expect(matches).to be true
      end

      it 'returns false for no argument matches' do
        argument_list_to_match = %w(first_argument)
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.args_match?(call_log_list)
        expect(matches).to be false
      end

      it 'returns true for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.args_match?(call_log_list)
        expect(matches).to be true
      end

      it 'returns true for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.args_match?(call_log_list)
        expect(matches).to be true
      end

      it 'returns false for "anything" matches that are not the exact count' do
        argument_list_to_match = [anything, anything, anything, anything]
        subject = CallLogArgumentListMatcher.new(argument_list_to_match)
        matches = subject.args_match?(call_log_list)
        expect(matches).to be false
      end

      it 'returns true for no expected argument list' do
        subject = CallLogArgumentListMatcher.new
        matches = subject.args_match?(call_log_list)
        expect(matches).to be true
      end

      it 'returns true for an empty expected argument list' do
        subject = CallLogArgumentListMatcher.new([])
        matches = subject.args_match?(call_log_list)
        expect(matches).to be true
      end
    end
  end
end
