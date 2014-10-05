require 'English'
require 'rspec/shell/expectations'

describe 'Replace shell commands' do
  include Rspec::Shell::Expectations

  describe 'running a file with non-existing commands' do
    it 'exits with an error' do
      `spec/fixtures/simple_script.sh 2>&1`
      expect($CHILD_STATUS.exitstatus).not_to eq 0
    end

    context 'with stubbed environment' do
      let(:stubbed_env) { create_stubbed_env }

      it 'exits with an error' do
        stubbed_env.execute 'spec/fixtures/simple_script.sh 2>&1'
        expect($CHILD_STATUS.exitstatus).not_to eq 0
      end

      context 'with a stubbed command' do
        before do
          stubbed_env.stub_command('command1')
        end

        it 'exits with status code 0' do
          stubbed_env.execute 'spec/fixtures/simple_script.sh 2>&1'
          expect($CHILD_STATUS.exitstatus).to eq 0
        end
      end
    end
  end
end
