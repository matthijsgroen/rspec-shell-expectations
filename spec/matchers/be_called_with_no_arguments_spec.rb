require 'English'
require 'rspec/bash'

describe 'be_called_with_no_arguments' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }

  context 'when command is called with no args' do
    before(:each) do
      @command = stubbed_env.stub_command('stubbed_command')
      @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(
        <<-multiline_script
          stubbed_command
        multiline_script
      )
    end
    it 'correctly identifies that no arguments were called' do
      expect(@command).to be_called_with_no_arguments
    end
  end
  context 'when command is called with args' do
    before(:each) do
      @command = stubbed_env.stub_command('stubbed_command')
      @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(
        <<-multiline_script
          stubbed_command argument
        multiline_script
      )
    end
    it 'correctly identifies that arguments were passed into command call' do
      expect(@command).to_not be_called_with_no_arguments
    end
  end
end
