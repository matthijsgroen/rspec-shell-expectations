require 'English'
require 'rspec/bash'

describe 'Assert called' do
  context 'checking command is called with argument sequence' do
    include Rspec::Shell::Expectations
    let(:stubbed_env) { create_stubbed_env }
    let!(:bundle) {
      stubbed_env.stub_command('bundle')
    }

    let(:script) do
      <<-SCRIPT
        bundle exec rake foo:bar
      SCRIPT
    end
    let(:script_path) { Pathname.new '/tmp/test_script.sh' }

    before do
      script_path.open('w') { |f| f.puts script }
      script_path.chmod 0777

      stubbed_env.execute script_path.to_s
    end

    after do
      script_path.delete
    end

    it 'is called with correct argument sequence' do
      expect(bundle).to be_called_with_arguments('exec', 'rake', 'foo:bar')
      expect(bundle).to be_called_with_arguments('exec', anything, 'foo:bar')
      expect(bundle).not_to be_called_with_arguments('exec', 'rake', 'foo')
    end
  end
  context 'checking command is called with no arguments' do
    include Rspec::Shell::Expectations
    let(:stubbed_env) { create_stubbed_env }
    let!(:ls) {
      stubbed_env.stub_command('ls')
    }

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
