require 'spec_helper'

describe 'CallLog' do
  let(:stubbed_env) { create_stubbed_env }
  let(:mock_log_file) { instance_double(File) }
  let(:mock_log_pathname) { instance_double(Pathname) }
  before(:each) do
    allow(mock_log_pathname).to receive(:open).with('w').and_yield(mock_log_file)
    allow(mock_log_file).to receive(:write).with(anything)
  end

  include Rspec::Bash

  context '#stdin_for_args' do
    it 'returns nil when no YAML file is used for call log' do
      @subject = Rspec::Bash::CallLog.new(nil)
      allow(YAML).to receive(:load_file).and_return([])

      expect(@subject.stdin_for_args(anything)).to be nil
    end
    it 'returns the stdin from call log when there is a single value for stdin' do
      actual_call_log = [{
        'args' => ['arbitrary argument'],
        'stdin' => ['correct value']
      }]
      @subject = Rspec::Bash::CallLog.new(mock_log_pathname)
      allow(@subject).to receive(:call_log).and_return(actual_call_log)

      expect(@subject.stdin_for_args('arbitrary argument').first).to eql 'correct value'
    end
    it 'returns the stdin from call log when there are multiple values for stdin' do
      actual_call_log = [{
        'args' => ['arbitrary argument'],
        'stdin' => ['first value', 'second value']
      }]
      @subject = Rspec::Bash::CallLog.new(mock_log_pathname)
      allow(@subject).to receive(:call_log).and_return(actual_call_log)

      expect(@subject.stdin_for_args('arbitrary argument').sort)
        .to eql ['first value', 'second value'].sort
    end
    it 'returns the stdin from call log when no arguments are provided' do
      actual_call_log =
        [{
          'args' => nil,
          'stdin' => ['correct value']
        }]
      @subject = Rspec::Bash::CallLog.new(mock_log_pathname)
      allow(@subject).to receive(:call_log).and_return(actual_call_log)

      expect(@subject.stdin_for_args).to eql ['correct value']
    end
  end
  context '#call_count?' do
    context 'with no calls made at all (missing call log file)' do
      before(:each) do
        @subject = Rspec::Bash::CallLog.new('command_with_no_call_log_file')
        allow(YAML).to receive(:load_file).and_raise(Errno::ENOENT)
      end

      it 'does not find an un-passed argument anywhere in the series' do
        expect(@subject.call_count('not_an_argument')).to eql 0
      end
    end
    context 'with only an series of arguments provided' do
      context 'and a command log with only one argument' do
        before(:each) do
          actual_call_log = [{
            'args' => ['first_arg'],
            'stdin' => []
          }]
          @subject = Rspec::Bash::CallLog.new('command_with_one_argument_log')
          allow(@subject).to receive(:call_log).and_return(actual_call_log)
        end

        it 'finds the single argument anywhere in the series exactly once' do
          expect(@subject.call_count('first_arg')).to eql 1
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.call_count('not_an_argument')).to eql 0
        end

        it 'finds the single wildcard argument exactly once' do
          expect(@subject.call_count(anything)).to eql 1
        end
      end
      context 'and a command called with two arguments' do
        before(:each) do
          actual_call_log = [{
            'args' => %w(first_arg second_arg),
            'stdin' => []
          }]
          @subject = Rspec::Bash::CallLog.new('command_with_two_arguments_log')
          allow(@subject).to receive(:call_log).and_return(actual_call_log)
        end

        it 'does not find the first argument when other argument is not provided' do
          expect(@subject.call_count('first_arg')).to eql 0
        end

        it 'finds the first argument anywhere in the series exactly once' do
          expect(@subject.call_count('first_arg', anything)).to eql 1
        end

        it 'does not find the second argument when first argument is not provided' do
          expect(@subject.call_count('second_arg')).to eql 0
        end

        it 'finds the second argument anywhere in the series exactly once' do
          expect(@subject.call_count(anything, 'second_arg')).to eql 1
        end

        it 'finds two contiguous arguments in the series exactly once' do
          expect(@subject.call_count('first_arg', 'second_arg')).to eql 1
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.call_count('not_an_argument')).to eql 0
        end

        it 'does not find a wildcard argument when other argument is not provided' do
          expect(@subject.call_count(anything)).to eql 0
        end

        it 'finds when both arguments are wildcards exactly once' do
          expect(@subject.call_count(anything, anything)).to eql 1
        end

        it 'finds when only the first argument is a wildcard exactly once' do
          expect(@subject.call_count(anything, 'second_arg')).to eql 1
        end

        it 'finds when only the second argument is a wildcard exactly once' do
          expect(@subject.call_count('first_arg', anything)).to eql 1
        end

        it 'does not find when wildcard is in wrong position' do
          expect(@subject.call_count('first_arg', anything, 'second_arg')).to eql 0
        end
      end
      context 'and a command called with three arguments' do
        before(:each) do
          actual_call_log = [{
            'args' => %w(first_arg second_arg third_arg),
            'stdin' => []
          }]
          @subject = Rspec::Bash::CallLog.new('command_with_three_arguments_log')
          allow(@subject).to receive(:call_log).and_return(actual_call_log)
        end

        it 'does not find first argument when other arguments are not provided' do
          expect(@subject.call_count('first_arg')).to eql 0
        end

        it 'finds the first argument anywhere in the series exactly once' do
          expect(@subject.call_count('first_arg', anything, anything)).to eql 1
        end

        it 'does not find second argument when other arguments are not provided' do
          expect(@subject.call_count('second_arg')).to eql 0
        end

        it 'finds the second argument anywhere in the series exactly once' do
          expect(@subject.call_count(anything, 'second_arg', anything)).to eql 1
        end

        it 'does not find third argument when other arguments are not provided' do
          expect(@subject.call_count('third_arg')).to eql 0
        end

        it 'finds the third argument anywhere in the series exactly once' do
          expect(@subject.call_count(anything, anything, 'third_arg')).to eql 1
        end

        it 'finds three contiguous arguments in the series exactly once' do
          expect(@subject.call_count('first_arg', 'second_arg', 'third_arg')).to eql 1
        end

        it 'does not find two non-contiguous arguments in the series exactly once' do
          expect(@subject.call_count('first_arg', 'third_arg')).to eql 0
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.call_count('not_an_argument')).to eql 0
        end

        it 'finds when only the first argument is a wildcard' do
          expect(@subject.call_count(anything, 'second_arg', 'third_arg')).to eql 1
        end

        it 'finds when only the second argument is a wildcard' do
          expect(@subject.call_count('first_arg', anything, 'third_arg')).to eql 1
        end

        it 'finds when only the third argument is a wildcard' do
          expect(@subject.call_count('first_arg', 'second_arg', anything)).to eql 1
        end

        it 'finds when both the first and second arguments are wildcards' do
          expect(@subject.call_count(anything, anything, 'third_arg')).to eql 1
        end

        it 'finds when both the first and third arguments are wildcards' do
          expect(@subject.call_count(anything, 'second_arg', anything)).to eql 1
        end

        it 'finds when both the second and third arguments are wildcards' do
          expect(@subject.call_count('first_arg', anything, anything)).to eql 1
        end

        it 'does not find when wildcard is in wrong position' do
          expect(@subject.call_count('first_arg', anything, 'second_arg', 'third_arg')).to eql 0
        end
      end
      context 'with an argument called multiple times' do
        before(:each) do
          actual_call_log = [
            {
              'args' => ['twice_called_arg'],
              'stdin' => []
            },
            {
              'args' => ['twice_called_arg'],
              'stdin' => []
            }
          ]
          @subject = Rspec::Bash::CallLog.new(anything)
          allow(@subject).to receive(:call_log).and_return(actual_call_log)
        end
        it 'returns 2 when argument is called 2 times' do
          expect(@subject.call_count('twice_called_arg')).to eql 2
        end
      end
    end
  end
  context '#called_with_args' do
    before(:each) do
      actual_call_log = [
        {
          'args' => ['once_called_arg'],
          'stdin' => []
        },
        {
          'args' => ['twice_called_arg'],
          'stdin' => []
        },
        {
          'args' => ['twice_called_arg'],
          'stdin' => []
        }
      ]
      @subject = Rspec::Bash::CallLog.new(anything)
      allow(@subject).to receive(:call_log).and_return(actual_call_log)
    end

    it 'returns false when there are no matching args' do
      expect(@subject.called_with_args?('no-match')).to be_falsey
    end

    it 'returns false when there is a single matching arg, but an extra argument' do
      expect(@subject.called_with_args?('once_called_arg', anything)).to be_falsey
    end

    it 'returns true when there are multiple matching args' do
      expect(@subject.called_with_args?('twice_called_arg')).to be_truthy
    end
  end
  context '#called_with_no_args?' do
    it 'returns false if no call log is found' do
      @subject = Rspec::Bash::CallLog.new(anything)
      allow(@subject).to receive(:call_log).and_return([])

      expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns true if no arguments are in call log' do
      actual_call_log = [{
        'args' => nil,
        'stdin' => []
      }]
      @subject = Rspec::Bash::CallLog.new(anything)
      allow(@subject).to receive(:call_log).and_return(actual_call_log)

      expect(@subject.called_with_no_args?).to be_truthy
    end
    it 'returns fails if a single argument is in call log' do
      actual_call_log = [{
        'args' => ['I am an argument'],
        'stdin' => []
      }]
      @subject = Rspec::Bash::CallLog.new(anything)
      allow(@subject).to receive(:call_log).and_return(actual_call_log)

      expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns fails if multiple arguments is in call log' do
      actual_call_log = [{
        'args' => ['I am an argument', 'as am I'],
        'stdin' => []
      }]
      @subject = Rspec::Bash::CallLog.new(anything)
      allow(@subject).to receive(:call_log).and_return(actual_call_log)

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
    context 'when setup is valid' do
      let(:mock_log_file) { instance_double(File) }
      let(:mock_log_pathname) { instance_double(Pathname) }
      subject { Rspec::Bash::CallLog.new(mock_log_pathname) }
      let(:log) do
        [{
          args: %w(first_argument second_argument),
          stdin: 'first_stdin'
        }]
      end
      context 'and no in-memory call log exists' do
        before(:each) do
          allow(mock_log_file).to receive(:read).and_return(log.to_yaml)
          allow(mock_log_pathname).to receive(:open).with('r').and_yield(mock_log_file)
        end

        it 'reads out what was in its configuration file' do
          expect(subject.call_log).to eql log
        end
      end
      context 'and an in-memory call log already exists' do
        before(:each) do
          subject.call_log = log
        end

        it 'reads out what was in its configuration file' do
          expect(subject.call_log).to eql log
        end
      end
    end
  end
end
