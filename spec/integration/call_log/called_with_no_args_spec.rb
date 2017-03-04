require 'spec_helper'

describe 'CallLog' do
  context '#called_with_no_args?' do
    include Rspec::Bash
    let(:stubbed_env) { create_stubbed_env }
    let!(:ls) { stubbed_env.stub_command('ls') }
    let(:script) do
      <<-SCRIPT
       ls
      SCRIPT
    end
    let(:script_path) { Pathname.new '/tmp/no_arg_test_script.sh' }

    before do
      script_path.open('w') { |f| f.puts script }
      script_path.chmod 0777

      stubbed_env.execute script_path.to_s
    end

    after do
      script_path.delete
    end

    it 'is called with no arguments' do
      expect(ls).to be_called_with_no_arguments
    end
  end
end
