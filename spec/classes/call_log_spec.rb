require 'spec_helper'
include Rspec::Bash
include Rspec::Bash::Util

describe 'CallLog' do
  let(:stubbed_env) { create_stubbed_env }
  let(:mock_log_file) { StringFileIO.new }
  let(:mock_log_pathname) { instance_double(Pathname) }
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
    allow(mock_log_pathname).to receive(:open).with('r').and_yield(mock_log_file)
    allow(mock_log_pathname).to receive(:open).with('w').and_yield(mock_log_file)
  end

  subject { CallLog.new(mock_log_pathname) }

  context '#stdin_for_args' do
    it 'returns the first matching stdin via the specialized matcher' do
      expect(mock_call_log_matcher).to receive(:get_call_log_matches)
        .with(any_args)
      expect(subject.stdin_for_args('first_argument', 'second_argument')).to eql 'first_stdin'
    end
  end
  context '#call_count?' do
    it 'returns the expected call count via the specialized matcher' do
      expect(mock_call_log_matcher).to receive(:get_call_count)
        .with(any_args)
      expect(subject.call_count('first_argument', 'second_argument')).to eql 3
    end
  end
  context '#called_with_args' do
    it 'returns the expected value via the specialized matcher' do
      expect(mock_call_log_matcher).to receive(:args_match?)
        .with(any_args)
      expect(subject.called_with_args?('first_argument', 'second_argument')).to eql true
    end
  end
  context '#called_with_no_args?' do
    it 'returns false if no call log is found' do
      @subject = Rspec::Bash::CallLog.new(mock_log_pathname)
      @subject.call_log = []

      expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns true if no arguments are in call log' do
      actual_call_log = [{
        args: nil,
        stdin: []
      }]
      @subject = Rspec::Bash::CallLog.new(mock_log_pathname)
      @subject.call_log = actual_call_log

      expect(@subject.called_with_no_args?).to be_truthy
    end
    it 'returns fails if a single argument is in call log' do
      actual_call_log = [{
        args: ['I am an argument'],
        stdin: []
      }]
      @subject = Rspec::Bash::CallLog.new(mock_log_pathname)
      @subject.call_log = actual_call_log

      expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns fails if multiple arguments is in call log' do
      actual_call_log = [{
        args: ['I am an argument', 'as am I'],
        stdin: []
      }]
      @subject = Rspec::Bash::CallLog.new(mock_log_pathname)
      @subject.call_log = actual_call_log

      expect(@subject.called_with_no_args?).to be_falsey
    end
  end

  context '#add_log' do
    context 'with any setup' do
      subject { Rspec::Bash::CallLog.new(mock_log_pathname) }

      context 'with no existing configuration' do
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

        it 'writes that log to its log file' do
          expect(mock_log_file).to receive(:write).with(expected_log.to_yaml)
          subject.add_log('first_stdin', %w(first_argument second_argument))
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

        it 'writes that log to its log file' do
          expect(mock_log_file).to receive(:write).with(expected_log.to_yaml)
          subject.add_log('second_stdin', %w(first_argument))
        end
      end
    end
    context 'with no config_path' do
      subject { Rspec::Bash::CallConfiguration.new(nil, anything) }
      it 'raises an error' do
        expect do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
        end.to raise_exception(NoMethodError)
      end
    end
  end
  context '#call_log' do
    context 'when there is no call_log_path' do
      subject { Rspec::Bash::CallLog.new(nil) }
      it 'returns an empty array' do
        expect(subject.call_log).to eql []
      end
    end
    context 'when the call log exists but is empty' do
      subject { Rspec::Bash::CallLog.new(mock_log_pathname) }
      before(:each) do
        allow(mock_log_file).to receive(:read).and_return('')
      end
      it 'returns an empty array' do
        expect(subject.call_log).to eql []
      end
    end
    context 'when the call log file open throws a file not found exception' do
      subject { Rspec::Bash::CallLog.new(mock_log_pathname) }
      before(:each) do
        allow(mock_log_pathname).to receive(:open).with('r').and_raise(Errno::ENOENT)
      end
      it 'returns an empty array' do
        expect(subject.call_log).to eql []
      end
    end
    context 'when setup is valid' do
      subject { Rspec::Bash::CallLog.new(mock_log_pathname) }
      let(:log) do
        [{
          args: %w(first_argument second_argument),
          stdin: 'first_stdin'
        }]
      end
      context 'and a call log exists' do
        before(:each) do
          allow(mock_log_file).to receive(:read).and_return(log.to_yaml)
        end

        it 'reads out what was in its configuration file' do
          expect(subject.call_log).to eql log
        end
      end
    end
  end
end
