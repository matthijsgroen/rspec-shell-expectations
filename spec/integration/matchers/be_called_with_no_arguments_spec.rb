require 'spec_helper'
include Rspec::Bash

describe 'RSpec::Matchers' do
  let(:stubbed_env) { create_stubbed_env }
  let!(:command) { stubbed_env.stub_command('stubbed_command') }

  context '.be_called_with_no_arguments' do
    context 'when command is called with no args' do
      before(:each) do
        stubbed_env.execute_inline(
          <<-multiline_script
          stubbed_command
        multiline_script
        )
      end
      it 'correctly identifies that no arguments were called' do
        expect(command).to be_called_with_no_arguments
      end
    end
    context 'when command is called with args' do
      before(:each) do
        stubbed_env.execute_inline(
          <<-multiline_script
          stubbed_command argument
        multiline_script
        )
      end
      it 'correctly identifies that arguments were passed into command call' do
        expect(command).to_not be_called_with_no_arguments
      end
    end
  end
end
