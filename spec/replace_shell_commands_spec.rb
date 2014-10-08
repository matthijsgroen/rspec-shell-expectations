require 'English'
require 'rspec/shell/expectations'

describe 'Replace shell commands' do
  include Rspec::Shell::Expectations
  let(:script) do
    <<-SCRIPT
      command1 "foo bar"
    SCRIPT
  end
  let(:script_path) { Pathname.new '/tmp/test_script.sh' }

  before do
    script_path.open('w') { |f| f.puts script }
    script_path.chmod 0777
  end

  after do
    script_path.delete
  end

  describe 'running a file with non-existing commands' do
    it 'exits with an error' do
      `#{script_path} 2>&1`
      expect($CHILD_STATUS.exitstatus).not_to eq 0
    end

    context 'with stubbed environment' do
      let(:stubbed_env) { create_stubbed_env }

      it 'exits with an error' do
        stubbed_env.execute "#{script_path} 2>&1"
        expect($CHILD_STATUS.exitstatus).not_to eq 0
      end

      context 'with a stubbed command' do
        before do
          stubbed_env.stub_command('command1')
        end

        it 'exits with status code 0' do
          _o, _e, s = stubbed_env.execute "#{script_path} 2>&1"
          expect(s.exitstatus).to eq 0
        end
      end
    end
  end
end
