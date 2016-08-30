require 'English'
require 'rspec/shell/expectations'

describe 'CallLog' do
  let(:stubbed_env) { create_stubbed_env }
  include Rspec::Shell::Expectations

  context '#contains_argument_series?' do
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
          expect(@subject.contains_argument_series?('first_argument')).to be_truthy
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.contains_argument_series?('not_an_argument')).to be_falsey
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
          expect(@subject.contains_argument_series?('first_argument')).to be_truthy
        end

        it 'finds the second argument anywhere in the series' do
          expect(@subject.contains_argument_series?('second_argument')).to be_truthy
        end

        it 'finds two contiguous arguments in the series' do
          expect(@subject.contains_argument_series?('first_argument', 'second_argument')).to be_truthy
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.contains_argument_series?('not_an_argument')).to be_falsey
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
          expect(@subject.contains_argument_series?('first_argument')).to be_truthy
        end

        it 'finds the second argument anywhere in the series' do
          expect(@subject.contains_argument_series?('second_argument')).to be_truthy
        end

        it 'finds the third argument anywhere in the series' do
          expect(@subject.contains_argument_series?('third_argument')).to be_truthy
        end

        it 'finds three contiguous arguments in the series' do
          expect(@subject.contains_argument_series?('first_argument', 'second_argument', 'third_argument')).to be_truthy
        end

        it 'does not find two non-contiguous arguments in the series' do
          expect(@subject.contains_argument_series?('first_argument', 'third_argument')).to be_falsey
        end

        it 'does not find an un-passed argument anywhere in the series' do
          expect(@subject.contains_argument_series?('not_an_argument')).to be_falsey
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
          expect(@subject.contains_argument_series?('first_argument', position: 0)).to be_truthy
        end

        it 'does not find an un-passed argument at the first position in the series' do
          expect(@subject.contains_argument_series?('not_an_argument', position: 0)).to be_falsey
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
          expect(@subject.contains_argument_series?('first_argument', position: 0)).to be_truthy
        end

        it 'finds the second argument at the second position in the series' do
          expect(@subject.contains_argument_series?('second_argument', position: 1)).to be_truthy
        end

        it 'does not find the first argument at the second position in the series' do
          expect(@subject.contains_argument_series?('first_argument', position: 1)).to be_falsey
        end

        it 'does not find the second argument at the first position in the series' do
          expect(@subject.contains_argument_series?('second_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the first position in the series' do
          expect(@subject.contains_argument_series?('not_an_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the second position in the series' do
          expect(@subject.contains_argument_series?('not_an_argument', position: 1)).to be_falsey
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
          expect(@subject.contains_argument_series?('first_argument', position: 0)).to be_truthy
        end

        it 'finds the second argument at the second position in the series' do
          expect(@subject.contains_argument_series?('second_argument', position: 1)).to be_truthy
        end

        it 'finds the third argument at the third position in the series' do
          expect(@subject.contains_argument_series?('third_argument', position: 2)).to be_truthy
        end

        it 'finds the three arguments in order at the first position in the series' do
          expect(@subject.contains_argument_series?('first_argument', 'second_argument', 'third_argument', position: 0)).to be_truthy
        end

        it 'finds the first two arguments in order at the first position in the series' do
          expect(@subject.contains_argument_series?('first_argument', 'second_argument', position: 0)).to be_truthy
        end

        it 'finds the last two arguments in order at the second position in the series' do
          expect(@subject.contains_argument_series?('second_argument', 'third_argument', position: 1)).to be_truthy
        end

        it 'does not find the first two arguments in order at the second position in the series' do
          expect(@subject.contains_argument_series?('first_argument', 'second_argument', position: 1)).to be_falsey
        end

        it 'does not find the last two arguments in order at the first position in the series' do
          expect(@subject.contains_argument_series?('second_argument', 'third_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the first position in the series' do
          expect(@subject.contains_argument_series?('not_an_argument', position: 0)).to be_falsey
        end

        it 'does not find an un-passed argument at the second position in the series' do
          expect(@subject.contains_argument_series?('not_an_argument', position: 1)).to be_falsey
        end

        it 'does not find an un-passed argument at the third position in the series' do
          expect(@subject.contains_argument_series?('not_an_argument', position: 2)).to be_falsey
        end
      end
    end
    context 'with a series of arguments and a series of sub-commands provided' do
      context 'and sub commands called with one argument' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => ['first_sub_command', 'first_sub_command_argument'],
                      'stdin' => [],
                  },
                  {
                      'args' => ['second_sub_command', 'second_sub_command_argument'],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('sub_commands_with_one_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the first argument of the first sub-command anywhere in the series' do
          expect(@subject.contains_argument_series?('first_sub_command_argument', sub_command_series: ['first_sub_command'])).to be_truthy
        end

        it 'finds the first argument of the second sub-command anywhere in the series' do
          expect(@subject.contains_argument_series?('second_sub_command_argument', sub_command_series: ['second_sub_command'])).to be_truthy
        end

        it 'does not find the first argument of the first sub-command on other sub-commands in the series' do
          expect(@subject.contains_argument_series?('first_sub_command_argument', sub_command_series: ['second_sub_command'])).to be_falsey
        end

        it 'does not find the first argument of the second sub-command on other sub-commands in the series' do
          expect(@subject.contains_argument_series?('second_sub_command_argument', sub_command_series: ['first_sub_command'])).to be_falsey
        end
      end
      context 'and sub commands called with two arguments' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => ['first_sub_command', 'first_sub_command_argument_one', 'first_sub_command_argument_two'],
                      'stdin' => [],
                  },
                  {
                      'args' => ['second_sub_command', 'second_sub_command_argument_one', 'second_sub_command_argument_two'],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('sub_commands_with_two_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the arguments of the first sub-command on the first sub-command in the series' do
          expect(@subject.contains_argument_series?('first_sub_command_argument_one', 'first_sub_command_argument_two', sub_command_series: ['first_sub_command'])).to be_truthy
        end

        it 'finds the arguments of the second sub-command on the second sub-command in the series' do
          expect(@subject.contains_argument_series?('second_sub_command_argument_one', 'second_sub_command_argument_two', sub_command_series: ['second_sub_command'])).to be_truthy
        end

        it 'does not find the arguments of the first sub-command on the second sub-command in the series' do
          expect(@subject.contains_argument_series?('first_sub_command_argument_one', 'first_sub_command_argument_two', sub_command_series: ['second_sub_command'])).to be_falsey
        end

        it 'does not find the arguments of the second sub-command on the first sub-command in the series' do
          expect(@subject.contains_argument_series?('second_sub_command_argument_one', 'second_sub_command_argument_two', sub_command_series: ['first_sub_command'])).to be_falsey
        end
      end
      context 'and sub commands called with three arguments' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => [
                          'first_sub_command',
                          'first_sub_command_argument_one',
                          'first_sub_command_argument_two',
                          'first_sub_command_argument_three',
                      ],
                      'stdin' => [],
                  },
                  {
                      'args' => [
                          'second_sub_command',
                          'second_sub_command_argument_one',
                          'second_sub_command_argument_two',
                          'second_sub_command_argument_three',
                      ],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('sub_commands_with_three_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end

        it 'finds the arguments of the first sub-command on the first sub-command in the series' do
          expect(@subject.contains_argument_series?('first_sub_command_argument_one', 'first_sub_command_argument_two', 'first_sub_command_argument_three', sub_command_series: ['first_sub_command'])).to be_truthy
        end

        it 'finds the arguments of the second sub-command on the second sub-command in the series' do
          expect(@subject.contains_argument_series?('second_sub_command_argument_one', 'second_sub_command_argument_two', 'second_sub_command_argument_three', sub_command_series: ['second_sub_command'])).to be_truthy
        end

        it 'does not find the arguments of the first sub-command on the second sub-command in the series' do
          expect(@subject.contains_argument_series?('first_sub_command_argument_one', 'first_sub_command_argument_two', 'first_sub_command_argument_three', sub_command_series: ['second_sub_command'])).to be_falsey
        end

        it 'does not find the arguments of the second sub-command on the first sub-command in the series' do
          expect(@subject.contains_argument_series?('second_sub_command_argument_one', 'second_sub_command_argument_two', 'second_sub_command_argument_three', sub_command_series: ['first_sub_command'])).to be_falsey
        end

        it 'does not find the non-contiguous arguments of the first sub-command on the first sub-command in the series' do
          expect(@subject.contains_argument_series?('first_sub_command_argument_one', 'first_sub_command_argument_three', sub_command_series: ['first_sub_command'])).to be_falsey
        end

        it 'does not find the non-contiguous arguments of the second sub-command on the second sub-command in the series' do
          expect(@subject.contains_argument_series?('second_sub_command_argument_one', 'second_sub_command_argument_three', sub_command_series: ['second_sub_command'])).to be_falsey
        end
      end
    end
    context 'with a series of arguments, a starting position, and a series of sub-commands provided' do
      context 'and sub commands called with one argument' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => ['first_sub_command', 'first_sub_command_argument'],
                      'stdin' => [],
                  },
                  {
                      'args' => ['second_sub_command', 'second_sub_command_argument'],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('sub_commands_with_one_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end
        it 'finds the first argument of the first sub-command in the first position in the series' do
          expect(@subject.contains_argument_series?(
              'first_sub_command_argument',
              sub_command_series: ['first_sub_command'],
              position: 0
          )).to be_truthy
        end

        it 'finds the first argument of the second sub-command in the first position in the series' do
          expect(@subject.contains_argument_series?(
              'second_sub_command_argument',
              sub_command_series: ['second_sub_command'],
              position: 0
          )).to be_truthy
        end

        it 'does not find the first argument of the first sub-command on other sub-commands in the series' do
          expect(@subject.contains_argument_series?(
              'first_sub_command_argument',
              sub_command_series: ['second_sub_command'],
              position: 0
          )).to be_falsey
        end

        it 'does not find the first argument of the second sub-command on other sub-commands in the series' do
          expect(@subject.contains_argument_series?(
              'second_sub_command_argument',
              sub_command_series: ['first_sub_command'],
              position: 0
          )).to be_falsey
        end
      end
      context 'and sub commands called with two arguments' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => ['first_sub_command', 'first_sub_command_argument_one', 'first_sub_command_argument_two'],
                      'stdin' => [],
                  },
                  {
                      'args' => ['second_sub_command', 'second_sub_command_argument_one', 'second_sub_command_argument_two'],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('sub_commands_with_two_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end
        it 'finds the arguments of the first sub-command in the first position on the first sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'first_sub_command_argument_two',
              sub_command_series: ['first_sub_command'],
              position: 1
          )).to be_truthy
        end

        it 'finds the arguments of the second sub-command in the first position on the second sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'second_sub_command_argument_two',
              sub_command_series: ['second_sub_command'],
              position: 1
          )).to be_truthy
        end

        it 'does not find the arguments of the first sub-command on the second sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'first_sub_command_argument_two',
              sub_command_series: ['second_sub_command'],
              position: 1
          )).to be_falsey
        end

        it 'does not find the arguments of the second sub-command on the first sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'second_sub_command_argument_two',
              sub_command_series: ['first_sub_command'],
              position: 1
          )).to be_falsey
        end
      end
      context 'and sub commands called with three arguments' do
        before(:each) do
          actual_call_log_list =
              [
                  {
                      'args' => [
                          'first_sub_command',
                          'first_sub_command_argument_one',
                          'first_sub_command_argument_two',
                          'first_sub_command_argument_three',
                      ],
                      'stdin' => [],
                  },
                  {
                      'args' => [
                          'second_sub_command',
                          'second_sub_command_argument_one',
                          'second_sub_command_argument_two',
                          'second_sub_command_argument_three',
                      ],
                      'stdin' => [],
                  }
              ]
          @subject = Rspec::Shell::Expectations::CallLog.new('sub_commands_with_three_arguments_log')
          allow(@subject).to receive(:load_call_log_list).and_return(actual_call_log_list)
        end
        it 'finds the arguments of the first sub-command in the second position on the first sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'first_sub_command_argument_two',
              'first_sub_command_argument_three',
              sub_command_series: ['first_sub_command'],
              position: 1
          )).to be_truthy
        end

        it 'finds the arguments of the second sub-command in the second position on the second sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'second_sub_command_argument_two',
              'second_sub_command_argument_three',
              sub_command_series: ['second_sub_command'],
              position: 1
          )).to be_truthy
        end

        it 'does not find the arguments of the first sub-command in the first position on the second sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'first_sub_command_argument_one',
              'first_sub_command_argument_two',
              'first_sub_command_argument_three',
              sub_command_series: ['second_sub_command'],
              position: 0
          )).to be_falsey
        end

        it 'does not find the arguments of the second sub-command in the first position on the first sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'second_sub_command_argument_one',
              'second_sub_command_argument_two',
              'second_sub_command_argument_three',
              sub_command_series: ['first_sub_command'],
              position: 0
          )).to be_falsey
        end

        it 'does not find the non-contiguous arguments of the first sub-command in the first position on the first sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'first_sub_command_argument_one',
              'first_sub_command_argument_three',
              sub_command_series: ['first_sub_command'],
              position: 0
          )).to be_falsey
        end

        it 'does not find the non-contiguous arguments of the second sub-command in the first position on the second sub-command in the series' do
          expect(@subject.contains_argument_series?(
              'second_sub_command_argument_one',
              'second_sub_command_argument_three',
              sub_command_series: ['second_sub_command'],
              position: 0
          )).to be_falsey
        end
      end
    end
  end
end