require 'spec_helper'

describe 'CallLog' do
  context '#called_with_no_args?' do
    include Rspec::Bash
    let(:stubbed_env) { create_stubbed_env }
    let!(:ls) { stubbed_env.stub_command('ls') }

    before do
      stubbed_env.execute_inline(
        <<-multiline_script
          ls
      multiline_script
      )
    end

    it 'is called with no arguments' do
      expect(ls).to be_called_with_no_arguments
    end
  end
end
