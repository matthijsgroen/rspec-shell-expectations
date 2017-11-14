require 'spec_helper'
include Rspec::Bash
include Rspec::Bash::Util

describe 'CallLog' do
  let(:stubbed_env) { create_stubbed_env }
  let(:mock_call_log_matcher) { instance_double(CallLogArgumentListMatcher) }
  before(:each) do
    allow(mock_call_log_matcher).to receive(:get_call_log_matches).and_return(
      [
        {
          args: %w(first_argument second_argument),
          stdin: 'first_stdin'
        },
        {
          args: %w(first_argument second_argument),
          stdin: 'second_stdin'
        },
        {
          args: %w(first_argument second_argument),
          stdin: 'third_stdin'
        }
      ]
    )
    allow(mock_call_log_matcher).to receive(:get_call_count).and_return(3)
    allow(mock_call_log_matcher).to receive(:args_match?).and_return(true)
    allow(CallLogArgumentListMatcher).to receive(:new).with(any_args)
      .and_return(mock_call_log_matcher)
  end

  subject { CallLog.new }

  context '#stdin_for_args' do
    it 'returns the first matching stdin via the specialized matcher' do
      expect(mock_call_log_matcher).to receive(:get_call_log_matches)
        .with(any_args)
      expect(subject.stdin_for_args(%w(first_argument second_argument))).to eql 'first_stdin'
    end
  end
  context '#call_count?' do
    it 'returns the expected call count via the specialized matcher' do
      expect(mock_call_log_matcher).to receive(:get_call_count)
        .with(any_args)
      expect(subject.call_count(%w(first_argument second_argument))).to eql 3
    end
  end
  context '#called_with_args' do
    it 'returns the expected value via the specialized matcher' do
      expect(mock_call_log_matcher).to receive(:args_match?)
        .with(any_args)
      expect(subject.called_with_args?(%w(first_argument second_argument))).to eql true
    end
  end
  context '#called_with_no_args?' do
    it 'returns false if no call log is found' do
      @subject = Rspec::Bash::CallLog.new
      @subject.call_log = []

      expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns true if no arguments are in call log' do
      actual_call_log = [{
        args: nil,
        stdin: []
      }]
      @subject = Rspec::Bash::CallLog.new
      @subject.call_log = actual_call_log

      expect(@subject.called_with_no_args?).to be_truthy
    end
    it 'returns fails if a single argument is in call log' do
      actual_call_log = [{
        args: ['I am an argument'],
        stdin: []
      }]
      @subject = Rspec::Bash::CallLog.new
      @subject.call_log = actual_call_log

      expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns fails if multiple arguments is in call log' do
      actual_call_log = [{
        args: ['I am an argument', 'as am I'],
        stdin: []
      }]
      @subject = Rspec::Bash::CallLog.new
      @subject.call_log = actual_call_log

      expect(@subject.called_with_no_args?).to be_falsey
    end
  end

  context '#add_log' do
    context 'with any setup' do
      subject { Rspec::Bash::CallLog.new }

      context 'with no existing log' do
        let(:expected_log) do
          [
            {
              args: %w(first_argument second_argument),
              stdin: 'first_stdin'
            }
          ]
        end
        it 'adds a call log for the arguments passed in' do
          subject.add_log('first_stdin', %w(first_argument second_argument))
          expect(subject.call_log).to eql expected_log
        end
      end
      context 'with an existing log' do
        let(:expected_log) do
          [
            {
              args: %w(first_argument second_argument),
              stdin: 'first_stdin'
            },
            {
              args: %w(first_argument),
              stdin: 'second_stdin'
            }
          ]
        end
        before(:each) do
          subject.call_log = [
            {
              args: %w(first_argument second_argument),
              stdin: 'first_stdin'
            }
          ]
        end
        it 'adds a call log for the arguments passed in' do
          subject.add_log('second_stdin', %w(first_argument))
          expect(subject.call_log).to eql expected_log
        end
      end
    end
  end
  context '#call_log' do
    context 'when the call log exists but is empty' do
      subject { Rspec::Bash::CallLog.new }
      it 'returns an empty array' do
        expect(subject.call_log).to eql []
      end
    end
  end
end
