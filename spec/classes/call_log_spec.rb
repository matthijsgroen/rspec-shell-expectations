require 'English'
require 'rspec/shell/expectations'

describe 'CallLog' do
  let(:stubbed_env) { create_stubbed_env }
  include Rspec::Shell::Expectations

  context '#stdin_for_args' do
    it 'returns nil when no YAML file is used for call log' do
        @subject = Rspec::Shell::Expectations::CallLog.new(anything)
        allow(YAML).to receive(:load_file).and_return([])

        expect(@subject.stdin_for_args(anything)).to be nil
    end
    it 'returns the stdin from call log when there is a single value for stdin' do
      actual_call_log_list =
        [{
           'args' => ['arbitrary argument'],
           'stdin' => ['correct value'],
        }]
      @subject = Rspec::Shell::Expectations::CallLog.new(anything)
      allow(YAML).to receive(:load_file).and_return(actual_call_log_list)

      expect(@subject.stdin_for_args('arbitrary argument').first).to eql 'correct value'
    end
    it 'returns the stdin from call log when there are multiple values for stdin' do
      actual_call_log_list =
        [{
           'args' => ['arbitrary argument'],
           'stdin' => ['first value', 'second value'],
        }]
      @subject = Rspec::Shell::Expectations::CallLog.new(anything)
      allow(YAML).to receive(:load_file).and_return(actual_call_log_list)

      expect(@subject.stdin_for_args('arbitrary argument').sort).to eql ['first value', 'second value'].sort
    end
  end

  context '#called_with_args?' do
    context 'with no calls made at all (missing call log file)' do
      before(:each) do
        @subject = Rspec::Shell::Expectations::CallLog.new('command_with_no_call_log_file')
        allow(YAML).to receive(:load_file).and_raise(Errno::ENOENT)
      end

      it 'does not find an un-passed argument anywhere in the series' do
        expect(@subject.called_with_args?('not_an_argument')).to be_falsey
      end
    end
    context 'with only an series of arguments provided' do
      context 'and a command log with only one argument' do
        before(:each) do
          actual_call_log_list =
              [{
                   'args' => ['first_argument'],
                   'stdin' => [],
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new('command_with_one_argument_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the single argument anywhere in the series' do
          expect(@subject.called_with_args?('first_argument')).to be_truthy
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.called_with_args?('not_an_argument')).to be_falsey
        end
        
        it 'finds the single wildcard argument' do
          expect(@subject.called_with_args?(anything)).to be_truthy
        end
      end
      context 'and a command called with two arguments' do
        before(:each) do
          actual_call_log_list =
              [{
                   'args' => ['first_argument', 'second_argument'],
                   'stdin' => [],
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new('command_with_two_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the first argument anywhere in the series' do
          expect(@subject.called_with_args?('first_argument')).to be_truthy
        end

        it 'finds the second argument anywhere in the series' do
          expect(@subject.called_with_args?('second_argument')).to be_truthy
        end

        it 'finds two contiguous arguments in the series' do
          expect(@subject.called_with_args?('first_argument', 'second_argument')).to be_truthy
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.called_with_args?('not_an_argument')).to be_falsey
        end

        it 'finds the single wildcard argument' do
          expect(@subject.called_with_args?(anything)).to be_truthy
        end
        
        it 'finds when both arguments are wildcards' do
          expect(@subject.called_with_args?(anything, anything)).to be_truthy
        end
        
        it 'finds when only the first argument is a wildcard' do
          expect(@subject.called_with_args?(anything, 'second_argument')).to be_truthy
        end
        
        it 'finds when only the second argument is a wildcard' do
          expect(@subject.called_with_args?('first_argument', anything)).to be_truthy
        end
        
        it 'does not find when wildcard is in wrong position' do
          expect(@subject.called_with_args?('first_argument', anything, 'second_argument')).to be_falsey
        end
      end
      context 'and a command called with three arguments' do
        before(:each) do
          actual_call_log_list =
              [{
                   'args' => ['first_argument', 'second_argument', 'third_argument'],
                   'stdin' => [],
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new('command_with_three_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the first argument anywhere in the series' do
          expect(@subject.called_with_args?('first_argument')).to be_truthy
        end

        it 'finds the second argument anywhere in the series' do
          expect(@subject.called_with_args?('second_argument')).to be_truthy
        end

        it 'finds the third argument anywhere in the series' do
          expect(@subject.called_with_args?('third_argument')).to be_truthy
        end

        it 'finds three contiguous arguments in the series' do
          expect(@subject.called_with_args?('first_argument', 'second_argument', 'third_argument')).to be_truthy
        end

        it 'does not find two non-contiguous arguments in the series' do
          expect(@subject.called_with_args?('first_argument', 'third_argument')).to be_falsey
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.called_with_args?('not_an_argument')).to be_falsey
        end
        it 'finds when only the first argument is a wildcard' do
          expect(@subject.called_with_args?(anything, 'second_argument', 'third_argument')).to be_truthy
        end
        it 'finds when only the second argument is a wildcard' do
          expect(@subject.called_with_args?('first_argument', anything, 'third_argument')).to be_truthy
        end
        it 'finds when only the third argument is a wildcard' do
          expect(@subject.called_with_args?('first_argument', 'second_argument', anything)).to be_truthy
        end
        it 'finds when both the first and second arguments are wildcards' do
          expect(@subject.called_with_args?(anything, anything, 'third_argument')).to be_truthy
        end
        it 'finds when both the first and third arguments are wildcards' do
          expect(@subject.called_with_args?(anything, 'second_argument', anything)).to be_truthy
        end
        it 'finds when both the second and third arguments are wildcards' do
          expect(@subject.called_with_args?('first_argument', anything, anything)).to be_truthy
        end
        it 'does not find when wildcard is in wrong position' do
          expect(@subject.called_with_args?('first_argument', anything, 'second_argument', 'third_argument')).to be_falsey
        end
      end
    end
    context 'with a series of arguments and a starting position provided' do
      context 'and a command called with one argument' do
        before(:each) do
          actual_call_log_list =
              [{
                   'args' => ['first_argument'],
                   'stdin' => [],
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new('command_with_one_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the single argument at the first position in the series' do
          expect(@subject.called_with_args?('first_argument', position: 0)).to be_truthy
        end

        it 'does not find an un-passed argument at the first position in the series' do
          expect(@subject.called_with_args?('not_an_argument', position: 0)).to be_falsey
        end
      end
      context 'and a command called with two arguments' do
        before(:each) do
          actual_call_log_list =
              [{
                   'args' => ['first_argument', 'second_argument'],
                   'stdin' => [],
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new('command_with_two_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the first argument at the first position in the series' do
          expect(@subject.called_with_args?('first_argument', position: 0)).to be_truthy
        end

        it 'finds the second argument at the second position in the series' do
          expect(@subject.called_with_args?('second_argument', position: 1)).to be_truthy
        end

        it 'does not find the first argument at the second position in the series' do
          expect(@subject.called_with_args?('first_argument', position: 1)).to be_falsey
        end

        it 'does not find the second argument at the first position in the series' do
          expect(@subject.called_with_args?('second_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the first position in the series' do
          expect(@subject.called_with_args?('not_an_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the second position in the series' do
          expect(@subject.called_with_args?('not_an_argument', position: 1)).to be_falsey
        end
      end
      context 'and a command called with three arguments' do
        before(:each) do
          actual_call_log_list =
              [{
                   'args' => ['first_argument', 'second_argument', 'third_argument'],
                   'stdin' => [],
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new('command_with_three_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the first argument at the first position in the series' do
          expect(@subject.called_with_args?('first_argument', position: 0)).to be_truthy
        end

        it 'finds the second argument at the second position in the series' do
          expect(@subject.called_with_args?('second_argument', position: 1)).to be_truthy
        end

        it 'finds the third argument at the third position in the series' do
          expect(@subject.called_with_args?('third_argument', position: 2)).to be_truthy
        end

        it 'finds the three arguments in order at the first position in the series' do
          expect(@subject.called_with_args?('first_argument', 'second_argument', 'third_argument', position: 0)).to be_truthy
        end

        it 'finds the first two arguments in order at the first position in the series' do
          expect(@subject.called_with_args?('first_argument', 'second_argument', position: 0)).to be_truthy
        end

        it 'finds the last two arguments in order at the second position in the series' do
          expect(@subject.called_with_args?('second_argument', 'third_argument', position: 1)).to be_truthy
        end

        it 'does not find the first two arguments in order at the second position in the series' do
          expect(@subject.called_with_args?('first_argument', 'second_argument', position: 1)).to be_falsey
        end

        it 'does not find the last two arguments in order at the first position in the series' do
          expect(@subject.called_with_args?('second_argument', 'third_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the first position in the series' do
          expect(@subject.called_with_args?('not_an_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the second position in the series' do
          expect(@subject.called_with_args?('not_an_argument', position: 1)).to be_falsey
        end

        it 'does not find an un-passed argument at the third position in the series' do
          expect(@subject.called_with_args?('not_an_argument', position: 2)).to be_falsey
        end
      end
    end

    context 'with multiple series of arguments' do
      context 'and called with no position' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => ['first_series_first_argument', 'first_series_second_argument'],
                      'stdin' => [],
                  },
                  {
                      'args' => ['second_series_first_argument', 'second_series_second_argument'],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('two_argument_series_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds both series when called in correct order' do
          expect(@subject.called_with_args?('first_series_first_argument', 'first_series_second_argument')).to be_truthy
          expect(@subject.called_with_args?('second_series_first_argument', 'second_series_second_argument')).to be_truthy
        end

        it 'does not find when arguments cross argument series' do
          expect(@subject.called_with_args?('first_series_first_argument', 'second_series_first_argument')).to be_falsey
          expect(@subject.called_with_args?('first_series_first_argument', 'second_series_second_argument')).to be_falsey
        end
      end
      context 'and called with a position' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => ['first_series_first_argument', 'first_series_second_argument'],
                      'stdin' => [],
                  },
                  {
                      'args' => ['second_series_first_argument', 'second_series_second_argument'],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('two_argument_series_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end
        
        it 'finds both series when called in correct order at starting position' do
          expect(@subject.called_with_args?('first_series_first_argument', 'first_series_second_argument', position: 0)).to be_truthy
          expect(@subject.called_with_args?('second_series_first_argument', 'second_series_second_argument', position: 0)).to be_truthy
        end
        
        it 'does not find when arguments cross argument series' do
          expect(@subject.called_with_args?('first_series_second_argument', position: 0)).to be_falsey
        end

        it 'finds the second argument from each series series' do
          expect(@subject.called_with_args?('first_series_second_argument', position: 1)).to be_truthy
          expect(@subject.called_with_args?('second_series_second_argument', position: 1)).to be_truthy
        end
      end
    end
  end

  context '#called_with_no_args?' do
    it 'returns false if no call log is found' do
        @subject = Rspec::Shell::Expectations::CallLog.new(anything)
        allow(YAML).to receive(:load_file).and_raise(Errno::ENOENT)

        expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns true if no arguments are in call log' do
      actual_call_log_list =
        [{
           'args' => nil,
           'stdin' => [],
        }]
        @subject = Rspec::Shell::Expectations::CallLog.new(anything)
        allow(YAML).to receive(:load_file).and_return(actual_call_log_list)

        expect(@subject.called_with_no_args?).to be_truthy
    end
    it 'returns fails if a single argument is in call log' do
      actual_call_log_list =
        [{
           'args' => ['I am an argument'],
           'stdin' => [],
        }]
        @subject = Rspec::Shell::Expectations::CallLog.new(anything)
        allow(YAML).to receive(:load_file).and_return(actual_call_log_list)

        expect(@subject.called_with_no_args?).to be_falsey
    end
    it 'returns fails if multiple arguments is in call log' do
      actual_call_log_list =
        [{
           'args' => ['I am an argument', 'as am I'],
           'stdin' => [],
        }]
        @subject = Rspec::Shell::Expectations::CallLog.new(anything)
        allow(YAML).to receive(:load_file).and_return(actual_call_log_list)

        expect(@subject.called_with_no_args?).to be_falsey
    end
  end
end
