require 'spec_helper'

describe 'lib/basic_functions.sh' do

  let(:stubbed_env) { create_stubbed_env }

  context('with basic functions') do
    context('with a function that calls a command') do
      before(:each) do
        @command_with_regular_arguments_command = stubbed_env.stub_command('command_with_regular_arguments_command')
        @stdout, @stderr, @status = stubbed_env.execute_function(
            './lib/basic_functions.sh',
            'command_with_regular_arguments'
        )
      end
      it 'returns no exit code' do
        expect(@stderr).to eq ''
        expect(@status.exitstatus).to eq 0
      end
      it 'calls its single command with both arguments' do
        expect(@command_with_regular_arguments_command).to be_called_with_arguments('first_argument', 'second_argument')
      end
      it 'calls its single command with both arguments in the first position' do
        expect(@command_with_regular_arguments_command).to be_called_with_arguments('first_argument', 'second_argument').at_position(0)
      end
      it 'calls its single command with first argument in the first position' do
        expect(@command_with_regular_arguments_command).to be_called_with_arguments('first_argument').at_position(0)
      end
      it 'calls its single command with second argument in the second position' do
        expect(@command_with_regular_arguments_command).to be_called_with_arguments('second_argument').at_position(1)
      end
    end
    context('with a function that calls a command with flagged arguments') do
      before(:each) do
        @command_with_flagged_arguments_command = stubbed_env.stub_command('command_with_flagged_arguments_command')
        @stdout, @stderr, @status = stubbed_env.execute_function(
            './lib/basic_functions.sh',
            'command_with_flagged_arguments'
        )
      end
      it 'returns no exit code' do
        expect(@stderr).to eq ''
        expect(@status.exitstatus).to eq 0
      end
      it 'calls its first flagged argument' do
        expect(@command_with_flagged_arguments_command).to be_called_with_arguments('--flag-one', 'first_argument')
      end
      it 'calls its first flagged arguments in the right position' do
        expect(@command_with_flagged_arguments_command).to be_called_with_arguments('--flag-one', 'first_argument').at_position(0)
      end
      it 'calls its second flagged arguments' do
        expect(@command_with_flagged_arguments_command).to be_called_with_arguments('--flag-two', 'second_argument')
      end
      it 'calls its second flagged arguments in the right position' do
        expect(@command_with_flagged_arguments_command).to be_called_with_arguments('--flag-two', 'second_argument').at_position(2)
      end
      it 'calls its third argument in the last position' do
        expect(@command_with_flagged_arguments_command).to be_called_with_arguments('third_argument').at_position(-1)
      end
    end
    context('with a function that calls a sub-command') do
      before(:each) do
        @command_with_regular_arguments_command = stubbed_env.stub_command('command_with_regular_arguments_command')
        @sub_command_with_regular_arguments_command = @command_with_regular_arguments_command.with_args('sub_command_with_regular_arguments_command')
        @stdout, @stderr, @status = stubbed_env.execute_function(
            './lib/basic_functions.sh',
            'sub_command_with_regular_arguments'
        )
      end
      it 'returns no exit code' do
        expect(@stderr).to eq ''
        expect(@status.exitstatus).to eq 0
      end
      it 'calls its single command with both arguments' do
        expect(@command_with_regular_arguments_command).to be_called_with_arguments('sub_command_with_regular_arguments_command', 'first_argument', 'second_argument')
      end
      it 'calls its single command with both arguments in the first position' do
        expect(@command_with_regular_arguments_command).to be_called_with_arguments('sub_command_with_regular_arguments_command', 'first_argument', 'second_argument').at_position(0)
      end
      it 'calls its single command with both arguments' do
        expect(@sub_command_with_regular_arguments_command).to be_called_with_arguments('first_argument', 'second_argument')
      end
      it 'calls its single command with both arguments in the first position' do
        expect(@sub_command_with_regular_arguments_command).to be_called_with_arguments('first_argument', 'second_argument').at_position(0)
      end
      it 'calls its single command with first argument in the first position' do
        expect(@sub_command_with_regular_arguments_command).to be_called_with_arguments('first_argument').at_position(0)
      end
      it 'calls its single command with second argument in the second position' do
        expect(@sub_command_with_regular_arguments_command).to be_called_with_arguments('second_argument').at_position(1)
      end
    end
    context('with a function that calls a sub-command with flagged arguments') do
      before(:each) do
        @command_with_flagged_arguments_command = stubbed_env.stub_command('command_with_flagged_arguments_command')
        @sub_command_with_flagged_arguments_command = @command_with_flagged_arguments_command.with_args('sub_command_with_flagged_arguments_command')
        @stdout, @stderr, @status = stubbed_env.execute_function(
            './lib/basic_functions.sh',
            'sub_command_with_flagged_arguments'
        )
      end
      it 'returns no exit code' do
        expect(@stderr).to eq ''
        expect(@status.exitstatus).to eq 0
      end
      it 'calls its first flagged argument' do
        expect(@command_with_flagged_arguments_command).to be_called_with_arguments('sub_command_with_flagged_arguments_command', '--flag-one', 'first_argument')
      end
      it 'calls its first flagged arguments in the right position' do
        expect(@command_with_flagged_arguments_command).to be_called_with_arguments('sub_command_with_flagged_arguments_command', '--flag-one', 'first_argument').at_position(0)
      end
      it 'calls its first flagged argument' do
        expect(@sub_command_with_flagged_arguments_command).to be_called_with_arguments('--flag-one', 'first_argument')
      end
      it 'calls its first flagged arguments in the right position' do
        expect(@sub_command_with_flagged_arguments_command).to be_called_with_arguments('--flag-one', 'first_argument').at_position(0)
      end
      it 'calls its second flagged arguments' do
        expect(@sub_command_with_flagged_arguments_command).to be_called_with_arguments('--flag-two', 'second_argument')
      end
      it 'calls its second flagged arguments in the right position' do
        expect(@sub_command_with_flagged_arguments_command).to be_called_with_arguments('--flag-two', 'second_argument').at_position(2)
      end
      it 'calls its third argument in the last position' do
        expect(@sub_command_with_flagged_arguments_command).to be_called_with_arguments('third_argument').at_position(-1)
      end
    end
  end
end