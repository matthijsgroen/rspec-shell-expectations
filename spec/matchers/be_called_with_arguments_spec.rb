require 'English'
require 'rspec/shell/expectations'

# TODO - the below specs test implementation, until the goofy wiring of StubbedCommand => StubbedCall => CallLog is sorted out

describe 'be_called_with_arguments' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }

  context 'with a command' do
    context 'and no chain calls' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
          stubbed_command first_argument second_argument
        multiline_script
        )
      end
      it 'correctly identifies the called arguments' do
        expect(@command).to be_called_with_arguments('first_argument', 'second_argument')
      end
    end
    context 'and the at_position chain call' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
          stubbed_command first_argument second_argument
        multiline_script
        )
      end
      it 'correctly identifies the called arguments' do
        expect(@command).to be_called_with_arguments('first_argument', 'second_argument').at_position(0)
      end
    end
    context 'and the times chain call' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
          stubbed_command duplicated_argument once_called_argument
          stubbed_command duplicated_argument
        multiline_script
        )
      end
      it 'matches when arguments are called twice' do
        expect(@command).to be_called_with_arguments('duplicated_argument').times(2)
      end
      it 'matches when argument is called once' do
        expect(@command).to be_called_with_arguments('once_called_argument').times(1)
      end
      it 'matches when argument combination is called once' do
        expect(@command).to be_called_with_arguments('duplicated_argument', 'once_called_argument').times(1)
      end
      it 'matches when argument is not called' do
        expect(@command).to_not be_called_with_arguments('not_called_argument').times(1)
      end
    end
  end
end
