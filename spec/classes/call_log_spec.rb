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
    it 'returns the stdin from call log when no arguments are provided' do
      actual_call_log_list =
        [{
           'args' => nil,
           'stdin' => ['correct value'],
         }]
      @subject = Rspec::Shell::Expectations::CallLog.new(anything)
      allow(YAML).to receive(:load_file).and_return(actual_call_log_list)

      expect(@subject.stdin_for_args).to eql ['correct value']
    end
  end

  context '#call_count?' do
    context 'with no calls made at all (missing call log file)' do
      before(:each) do
        @subject = Rspec::Shell::Expectations::CallLog.new('command_with_no_call_log_file')
        allow(YAML).to receive(:load_file).and_raise(Errno::ENOENT)
      end

      it 'does not find an un-passed argument anywhere in the series' do
        expect(@subject.call_count('not_an_argument')).to eql 0
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

        it 'finds the single argument anywhere in the series exactly once' do
          expect(@subject.call_count('first_argument')).to eql 1
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
          actual_call_log_list =
              [{
                   'args' => ['first_argument', 'second_argument'],
                   'stdin' => [],
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new('command_with_two_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end
        
        it 'does not find the first argument when other argument is not provided' do
          expect(@subject.call_count('first_argument')).to eql 0
        end

        it 'finds the first argument anywhere in the series exactly once' do
          expect(@subject.call_count('first_argument', anything)).to eql 1
        end

        it 'does not find the second argument when first argument is not provided' do
          expect(@subject.call_count('second_argument')).to eql 0
        end

        it 'finds the second argument anywhere in the series exactly once' do
          expect(@subject.call_count(anything, 'second_argument')).to eql 1
        end

        it 'finds two contiguous arguments in the series exactly once' do
          expect(@subject.call_count('first_argument', 'second_argument')).to eql 1
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
          expect(@subject.call_count(anything, 'second_argument')).to eql 1
        end

        it 'finds when only the second argument is a wildcard exactly once' do
          expect(@subject.call_count('first_argument', anything)).to eql 1
        end

        it 'does not find when wildcard is in wrong position' do
          expect(@subject.call_count('first_argument', anything, 'second_argument')).to eql 0
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

        it 'does not find first argument when other arguments are not provided' do
          expect(@subject.call_count('first_argument')).to eql 0
        end

        it 'finds the first argument anywhere in the series exactly once' do
          expect(@subject.call_count('first_argument', anything, anything)).to eql 1
        end

        it 'does not find second argument when other arguments are not provided' do
          expect(@subject.call_count('second_argument')).to eql 0
        end

        it 'finds the second argument anywhere in the series exactly once' do
          expect(@subject.call_count(anything, 'second_argument', anything)).to eql 1
        end

        it 'does not find third argument when other arguments are not provided' do
          expect(@subject.call_count('third_argument')).to eql 0
        end

        it 'finds the third argument anywhere in the series exactly once' do
          expect(@subject.call_count(anything, anything, 'third_argument')).to eql 1
        end

        it 'finds three contiguous arguments in the series exactly once' do
          expect(@subject.call_count('first_argument', 'second_argument', 'third_argument')).to eql 1
        end

        it 'does not find two non-contiguous arguments in the series exactly once' do
          expect(@subject.call_count('first_argument', 'third_argument')).to eql 0
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.call_count('not_an_argument')).to eql 0
        end

        it 'finds when only the first argument is a wildcard' do
          expect(@subject.call_count(anything, 'second_argument', 'third_argument')).to eql 1
        end

        it 'finds when only the second argument is a wildcard' do
          expect(@subject.call_count('first_argument', anything, 'third_argument')).to eql 1
        end

        it 'finds when only the third argument is a wildcard' do
          expect(@subject.call_count('first_argument', 'second_argument', anything)).to eql 1
        end

        it 'finds when both the first and second arguments are wildcards' do
          expect(@subject.call_count(anything, anything, 'third_argument')).to eql 1
        end

        it 'finds when both the first and third arguments are wildcards' do
          expect(@subject.call_count(anything, 'second_argument', anything)).to eql 1
        end

        it 'finds when both the second and third arguments are wildcards' do
          expect(@subject.call_count('first_argument', anything, anything)).to eql 1
        end
        
        it 'does not find when wildcard is in wrong position' do
          expect(@subject.call_count('first_argument', anything, 'second_argument', 'third_argument')).to eql 0
        end
      end
      context 'with an argument called multiple times' do
        before(:each) do
          actual_call_log_list =
              [{
                   'args' => ['twice_called_arg'],
                   'stdin' => []
               },
               {
                   'args' => ['twice_called_arg'],
                   'stdin' => []
               }]
          @subject = Rspec::Shell::Expectations::CallLog.new(anything)
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end
        it 'returns 2 when argument is called 2 times' do
          expect(@subject.call_count('twice_called_arg')).to eql 2
        end
      end
    end
    context 'with multiple series of arguments' do
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
  end

  context '#called_with_args' do
    before(:each) do
      actual_call_log_list =
          [{
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
           }]
      @subject = Rspec::Shell::Expectations::CallLog.new(anything)
      allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
    end

    it 'returns false when there are no matching args' do
      expect(@subject.called_with_args?('no-match')).to be_falsey
    end
    
    it 'returns true when there is a single matching arg' do
      expect(@subject.called_with_args?('once_called_arg', anything)).to be_truthy
    end
    
    it 'returns true when there are multiple matching args' do
      expect(@subject.called_with_args?('twice_called_arg')).to be_truthy
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
