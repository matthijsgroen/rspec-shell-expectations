require 'spec_helper'

describe 'StubbedEnv' do
  include Rspec::Bash

  context '#execute(path, ...)' do
    describe 'running a file with non-existing commands' do
      it 'exits with an error' do
        `command1 "foo bar" 2>&1`
        expect($CHILD_STATUS.exitstatus).not_to eq 0
      end

      context 'with stubbed environment' do
        let(:stubbed_env) { create_stubbed_env }

        it 'exits with an error' do
          stubbed_env.execute_inline 'command1 "foo bar" 2>&1'
          expect($CHILD_STATUS.exitstatus).not_to eq 0
        end

        context 'with a stubbed command' do
          before do
            stubbed_env.stub_command('command1')
          end

          it 'exits with status code 0' do
            _, _, status = stubbed_env.execute_inline 'command1 "foo bar" 2>&1'
            expect(status.exitstatus).to eq 0
          end
        end
      end
    end
  end
end
