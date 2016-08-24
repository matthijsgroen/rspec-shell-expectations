require 'English'
require 'rspec/shell/expectations'

# TODO - the below specs test implementation, until the goofy wiring of StubbedCommand => StubbedCall => CallLog is sorted out

describe 'be_called_with_no_arguments' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }

  context 'a command' do
    before(:each) do
      @command = stubbed_env.stub_command('stubbed_command')
      @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
        stubbed_command
      multiline_script
      )
    end
    it 'no arguments' do
      expect(@command).to be_called_with_no_arguments
    end
  end
  context 'a command with args' do
    before(:each) do
      @command = stubbed_env.stub_command('stubbed_command')
      @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
        stubbed_command argument
      multiline_script
      )
    end
    it 'yes arguments' do
      expect(@command).to_not be_called_with_no_arguments
    end
  end
end
